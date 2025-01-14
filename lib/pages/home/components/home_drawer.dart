// home_drawer.dart
import 'package:flutter/material.dart';
import '../../../components/user/sign_up_page.dart';
import '../../../components/utils/bottom_nav_bar.dart';
import '../../../components/services/auth_service.dart'; // Add this import
import '../../more/pages/more_page.dart';
import '../../schedule/pages/schedule_page.dart';
import '../../tracking/pages/tracking_page.dart';
import '../pages/home_page.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService(); // Add this

  final List<Widget> _screens = [
    HomeContent(),
    TrackingScreen(),
    SchedulePage(),
    MoreScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginSelectionScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showProfileDialog() {
    String name = _authService.currentUser?.displayName ?? "";
    String email = _authService.currentUser?.email ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: name,
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                ),
                onChanged: (value) {
                  // Handle city input
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle profile picture editing
                },
                child: Text('Edit Profile Picture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Sign Out'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save user info
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title: Text(user != null ? 'Hello, ${user.displayName ?? "User"}!' : 'Hello! User'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: user != null ? _showProfileDialog : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginSelectionScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  if (user != null) ...[
                    SizedBox(height: 10),
                    Text(
                      user.email ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (user == null) ...[
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginSelectionScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.app_registration),
                title: Text('Sign Up'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: _showProfileDialog,
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign Out'),
                onTap: _signOut,
              ),
            ],
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: MyBottomNavBar(
        onTabTapped: _onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}