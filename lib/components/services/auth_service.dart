// lib/services/auth_service.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
//
//
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId: '292559066781-1s0g14fha7tlvjo23a05bci5e7uu57k5.apps.googleusercontent.com',
//     scopes: ['email', 'profile'],
//   );
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//
//   // Stream to monitor auth state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//
//   // Get current user
//   User? get currentUser => _auth.currentUser;
//
//   // Check if user is logged in
//   bool get isUserLoggedIn => _auth.currentUser != null;
//
//   // Get user role
//   Future<String> getUserRole(String userId) async {
//     try {
//       DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
//       return doc.get('role') as String? ?? 'user';
//     } catch (e) {
//       return 'user'; // Default role
//     }
//   }
//
//   // Sign in with email and password
//   Future<User?> signIn(String email, String password) async {
//     try {
//       // Input validation
//       if (email.isEmpty || password.isEmpty) {
//         throw 'Email and password cannot be empty';
//       }
//
//       final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // Update last login timestamp
//       await _updateUserLoginData(userCredential.user?.uid, 'email');
//
//       return userCredential.user;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   // Sign in with Google
//   Future<User?> signInWithGoogle() async {
//     try {
//       // Clear any previous sign in
//       await _googleSignIn.signOut();
//
//       // Begin interactive sign in process
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null;
//
//       // Obtain auth details from request
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       // Create credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       // Sign in to Firebase with credential
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//
//       // Create/update user document in Firestore
//       if (userCredential.user != null) {
//         await _firestore.collection('users').doc(userCredential.user!.uid).set({
//           'name': userCredential.user!.displayName,
//           'email': userCredential.user!.email,
//           'photoURL': userCredential.user!.photoURL,
//           'lastLogin': FieldValue.serverTimestamp(),
//           'loginMethod': 'google',
//           'role': 'user', // Default role for new users
//           'status': 'active',
//         }, SetOptions(merge: true));
//       }
//
//       return userCredential.user;
//     } catch (e) {
//       if (e is PlatformException) {
//         if (e.code == 'sign_in_canceled') {
//           throw 'Sign in was canceled';
//         }
//       }
//       throw 'Failed to sign in with Google: ${e.toString()}';
//     }
//   }
//
//   // Sign up with email
//   Future<User?> signUp(String email, String password, String name) async {
//     try {
//       if (!_validateSignUpInput(email, password, name)) {
//         throw 'Invalid input data';
//       }
//
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final user = userCredential.user;
//       if (user == null) throw 'Failed to create user';
//
//       // Update profile and send verification
//       await Future.wait([
//         user.updateDisplayName(name),
//         user.sendEmailVerification(),
//         _createUserDocument(user.uid, name, email),
//       ]);
//
//       return user;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   // Sign out
//   Future<void> signOut() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId != null) {
//         await _firestore.collection('users').doc(userId).update({
//           'lastLogout': FieldValue.serverTimestamp(),
//         });
//       }
//
//       await Future.wait([
//         _googleSignIn.signOut(),
//         _auth.signOut(),
//         _secureStorage.deleteAll(),
//       ]);
//     } catch (e) {
//       throw 'Failed to sign out: ${e.toString()}';
//     }
//   }
//
//   // Reset password
//   Future<void> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   // Update user profile
//   Future<void> updateProfile({
//     String? displayName,
//     String? photoURL,
//     String? phoneNumber,
//   }) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw 'No user logged in';
//
//       final updates = <Future>[];
//
//       if (displayName != null) {
//         updates.add(user.updateDisplayName(displayName));
//       }
//       if (photoURL != null) {
//         updates.add(user.updatePhotoURL(photoURL));
//       }
//
//       updates.add(_firestore.collection('users').doc(user.uid).update({
//         if (displayName != null) 'name': displayName,
//         if (photoURL != null) 'photoURL': photoURL,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }));
//
//       await Future.wait(updates);
//     } catch (e) {
//       throw 'Failed to update profile: ${e.toString()}';
//     }
//   }
//
//   // Change password
//   Future<void> changePassword(String currentPassword, String newPassword) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null || user.email == null) throw 'No user logged in';
//
//       // Reauthenticate user before changing password
//       final credential = EmailAuthProvider.credential(
//         email: user.email!,
//         password: currentPassword,
//       );
//       await user.reauthenticateWithCredential(credential);
//
//       // Validate new password
//       if (!_isPasswordValid(newPassword)) {
//         throw 'Password must be at least 8 characters with uppercase, number, and special character';
//       }
//
//       await user.updatePassword(newPassword);
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   // Delete account
//   Future<void> deleteAccount() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw 'No user logged in';
//
//       // Delete user data from Firestore
//       await _firestore.collection('users').doc(user.uid).delete();
//
//       // Delete user authentication
//       await user.delete();
//
//       // Clear local storage
//       await _secureStorage.deleteAll();
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }
//
//   // Private helper methods
//   Future<void> _updateUserLoginData(String? userId, String loginMethod) async {
//     if (userId == null) return;
//
//     await _firestore.collection('users').doc(userId).update({
//       'lastLogin': FieldValue.serverTimestamp(),
//       'loginMethod': loginMethod,
//       'lastLoginIP': await _getClientIP(),
//     });
//   }
//
//   Future<void> _createUserDocument(String userId, String name, String email) async {
//     await _firestore.collection('users').doc(userId).set({
//       'name': name,
//       'email': email,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//       'lastLogin': FieldValue.serverTimestamp(),
//       'isEmailVerified': false,
//       'role': 'user',
//       'status': 'active',
//       'deviceInfo': await _getDeviceInfo(),
//     });
//   }
//
//   bool _validateSignUpInput(String email, String password, String name) {
//     if (email.isEmpty || password.isEmpty || name.isEmpty) return false;
//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) return false;
//     return _isPasswordValid(password);
//   }
//
//   bool _isPasswordValid(String password) {
//     return password.length >= 8 &&
//         RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password);
//   }
//
//   Future<String> _getClientIP() async {
//     // Implement IP address detection logic here
//     return 'Unknown';
//   }
//
//   Future<Map<String, dynamic>> _getDeviceInfo() async {
//     // Implement device info collection logic here
//     return {
//       'platform': 'Unknown',
//       'deviceModel': 'Unknown',
//       'appVersion': 'Unknown',
//     };
//   }
//
//   String _handleAuthError(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//         return 'No user found with this email';
//       case 'wrong-password':
//         return 'Incorrect password';
//       case 'email-already-in-use':
//         return 'Email is already registered';
//       case 'invalid-email':
//         return 'Invalid email format';
//       case 'weak-password':
//         return 'Password is too weak';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later';
//       case 'invalid-credential':
//         return 'Wrong email or password';
//       case 'requires-recent-login':
//         return 'Please sign in again to complete this action';
//       default:
//         return 'Authentication failed: ${e.message}';
//     }
//   }
// }

// Import necessary packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waste_management_tracking/utils/encryption_util.dart';

import '../utils/encryption_util.dart'; // Use encryption utility functions

class AuthService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '292559066781-1s0g14fha7tlvjo23a05bci5e7uu57k5.apps.googleusercontent.com', // Replace with your actual client ID
    scopes: ['email', 'profile'],
  );

  // Secure storage for sensitive local data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Stream to monitor authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Check if the user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  // Get the role of a user
  Future<String> getUserRole(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      // Decrypt sensitive data (if needed)
      final encryptedEmail = doc.get('email') as String;
      final decryptedEmail = EncryptionUtil.decryptData(encryptedEmail);

      print('Decrypted Email: $decryptedEmail'); // Log or use as required

      return doc.get('role') as String? ?? 'user';
    } catch (e) {
      return 'user'; // Default role
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password cannot be empty';
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _updateUserLoginData(userCredential.user?.uid, 'email');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign up with email and password
  Future<User?> signUp(String email, String password, String name) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw 'All fields are required';
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw 'Failed to create user';

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
      await Future.wait([
        _googleSignIn.signOut(), // Sign out from Google
        _auth.signOut(),        // Sign out from Firebase Auth
        _secureStorage.deleteAll(), // Clear local secure storage
      ]);
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }


  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Ensure no previous session exists

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName,
          'email': EncryptionUtil.encryptData(userCredential.user!.email ?? ''), // Encrypt email
          'photoURL': userCredential.user!.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'role': 'user',
          'status': 'active',
        }, SetOptions(merge: true));
      }

      return userCredential.user;
    } catch (e) {
      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw 'The email address is not valid.';
        case 'user-not-found':
          throw 'No user found with this email address.';
        default:
          throw 'An unexpected error occurred: ${e.message}';
      }
    } catch (e) {
      throw 'Failed to reset password. Please try again.';
    }
  }

  // Private helper: Create user document
  Future<void> _createUserDocument(String userId, String name, String email) async {
    final encryptedEmail = EncryptionUtil.encryptData(email);

    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': encryptedEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'role': 'user',
      'status': 'active',
    });
  }

  // Private helper: Update user login data
  Future<void> _updateUserLoginData(String? userId, String loginMethod) async {
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'lastLogin': FieldValue.serverTimestamp(),
      'loginMethod': loginMethod,
    });
  }

  // Handle authentication errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}


