import 'package:flutter/material.dart';
import 'package:waste_management_tracking/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Settings'),
            onTap: () {
              // Navigate to profile settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            onTap: () {
              // Navigate to notification settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              // Show language selection dialog
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Show about dialog
              showAboutDialog(
                context: context,
                applicationName: 'Waste Management Tracking',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Your Company',
              );
            },
          ),
        ),
      ],
    );
  }
}