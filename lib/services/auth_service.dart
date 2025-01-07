// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Stream to monitor auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      // Input validation
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password cannot be empty';
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      await _updateUserLoginData(userCredential.user?.uid, 'email');

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Show loading state
      // Begin the interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in
      if (googleUser == null) return null;

      try {
        // Obtain auth details from request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential for Firebase
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        // After successful sign in, update user data
        if (userCredential.user != null) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': userCredential.user!.displayName,
            'email': userCredential.user!.email,
            'photoURL': userCredential.user!.photoURL,
            'lastLogin': FieldValue.serverTimestamp(),
            'loginMethod': 'google',
          }, SetOptions(merge: true));
        }

        return userCredential.user;
      } catch (e) {
        // Handle specific Google Sign-In errors
        print('Error during Google Sign In authentication: $e');
        throw 'Failed to authenticate with Google. Please try again.';
      }
    } on PlatformException catch (e) {
      print('Platform Exception during Google Sign In: $e');
      if (e.code == 'sign_in_failed') {
        throw 'Google Sign In was cancelled or failed. Please try again.';
      } else {
        throw 'An error occurred during Google Sign In. Please try again.';
      }
    } catch (e) {
      print('Unexpected error during Google Sign In: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign up with email
  Future<User?> signUp(String email, String password, String name) async {
    try {
      if (!_validateSignUpInput(email, password, name)) {
        throw 'Invalid input data';
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw 'Failed to create user';

      // Update profile and send verification
      await Future.wait([
        user.updateDisplayName(name),
        user.sendEmailVerification(),
        _createUserDocument(user.uid, name, email),
      ]);

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'lastLogout': FieldValue.serverTimestamp(),
        });
      }

      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
        _secureStorage.deleteAll(),
      ]);
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      final updates = <Future>[];

      if (displayName != null) {
        updates.add(user.updateDisplayName(displayName));
      }
      if (photoURL != null) {
        updates.add(user.updatePhotoURL(photoURL));
      }

      updates.add(_firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'name': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }));

      await Future.wait(updates);
    } catch (e) {
      throw 'Failed to update profile: ${e.toString()}';
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) throw 'No user logged in';

      // Reauthenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Validate new password
      if (!_isPasswordValid(newPassword)) {
        throw 'Password must be at least 8 characters with uppercase, number, and special character';
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Private helper methods
  Future<void> _updateUserLoginData(String? userId, String loginMethod) async {
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'lastLogin': FieldValue.serverTimestamp(),
      'loginMethod': loginMethod,
      'lastLoginIP': await _getClientIP(),
    });
  }

  Future<void> _createUserDocument(String userId, String name, String email) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isEmailVerified': false,
      'role': 'user',
      'status': 'active',
      'deviceInfo': await _getDeviceInfo(),
    });
  }

  bool _validateSignUpInput(String email, String password, String name) {
    if (email.isEmpty || password.isEmpty || name.isEmpty) return false;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) return false;
    return _isPasswordValid(password);
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password);
  }

  Future<String> _getClientIP() async {
    // Implement IP address detection logic here
    return 'Unknown';
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Implement device info collection logic here
    return {
      'platform': 'Unknown',
      'deviceModel': 'Unknown',
      'appVersion': 'Unknown',
    };
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email format';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'invalid-credential':
        return 'Wrong email or password';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}