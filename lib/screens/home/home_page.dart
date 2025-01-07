import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste_management_tracking/services/auth_service.dart';
import 'package:waste_management_tracking/screens/auth/sign_in_page.dart';
import 'package:waste_management_tracking/screens/map/area_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  void _showProfileDialog() {
    final user = _authService.currentUser;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.person, size: 40, color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Management'),
        backgroundColor: Colors.lightGreen,
        actions: [
          if (user == null)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/sign-in');
              },
              child: const Text(
                'Sign In',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: _showProfileDialog,
            ),
        ],
      ),
      drawer: user != null ? _buildProfileDrawer(user) : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const TrackingScreen(),
          const ScheduleScreen(),
          const MoreScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.lightGreen,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user.displayName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            accountName: Text(
              user.displayName ?? 'User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(user.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Track Waste Collection'),
              subtitle: const Text('View real-time tracking'),
              onTap: () {
                setState(() {
                  _currentIndex = 1; // Switch to tracking tab
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Updates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('New Feature Added'),
              subtitle: const Text('Real-time waste collection tracking is now available'),
              trailing: const Icon(Icons.new_releases),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('System Update'),
              subtitle: const Text('Performance improvements and bug fixes'),
              trailing: const Icon(Icons.system_update),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    if (_authService.currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please sign in to access tracking features',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/sign-in');
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }

    return const AreaSelector();
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Schedule Coming Soon'),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildMoreOption(context, Icons.settings, 'Settings'),
        _buildMoreOption(context, Icons.privacy_tip, 'Privacy Policy'),
        _buildMoreOption(context, Icons.description, 'Terms and Conditions'),
        _buildMoreOption(context, Icons.help_outline, 'FAQ'),
        _buildMoreOption(context, Icons.info, 'About Us'),
        _buildMoreOption(context, Icons.feedback, 'Feedback'),
        _buildMoreOption(context, Icons.contact_mail, 'Contact Us'),
      ],
    );
  }

  Widget _buildMoreOption(BuildContext context, IconData icon, String label) {
    return Card(
      color: Colors.green[50],
      child: InkWell(
        onTap: () => _showDialog(context, label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String label) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: _getDialogContent(label),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _getDialogContent(String label) {
    switch (label) {
      case 'Settings':
        return const Text('Settings options will be available soon.');
      case 'Privacy Policy':
        return const Text('Our privacy policy details will be added here.');
      case 'Terms and Conditions':
        return const Text('Terms and conditions will be displayed here.');
      case 'FAQ':
        return const Text('Frequently asked questions will be listed here.');
      case 'About Us':
        return const Text('Information about our organization will be added here.');
      case 'Feedback':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide your feedback:'),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your feedback here...',
              ),
            ),
          ],
        );
      case 'Contact Us':
        return const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@wastetrack.com'),
            Text('Phone: +94 11 234 5678'),
            Text('Address: Colombo, Sri Lanka'),
          ],
        );
      default:
        return const Text('Content coming soon');
    }
  }
}