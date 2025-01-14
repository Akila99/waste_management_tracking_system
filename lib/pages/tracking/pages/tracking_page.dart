import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../components/services/auth_service.dart';
import '../../../components/user/sign_in_page.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    // Get current user
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking'),
      ),
      body: user != null ? _buildTrackingContent() : _buildSignInPrompt(),
    );
  }

  Widget _buildTrackingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add your tracking content here
          Text(
            'Welcome to Live Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Your tracking features will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          // Add more tracking-related widgets
        ],
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign in to use the Live Tracking feature',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}