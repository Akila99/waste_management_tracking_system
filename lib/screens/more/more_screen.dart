// lib/screens/more/more_screen.dart

import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: const [
        MoreOption(icon: Icons.settings, label: 'Settings'),
        MoreOption(icon: Icons.privacy_tip, label: 'Privacy Policy'),
        MoreOption(icon: Icons.description, label: 'Terms and Conditions'),
        MoreOption(icon: Icons.help_outline, label: 'FAQ'),
        MoreOption(icon: Icons.info, label: 'About Us'),
        MoreOption(icon: Icons.feedback, label: 'Feedback'),
        MoreOption(icon: Icons.contact_mail, label: 'Contact Us'),
      ],
    );
  }
}

class MoreOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const MoreOption({
    super.key,
    required this.icon,
    required this.label,
  });

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: _getContent(context),
        actions: [
          if (label == 'Settings')
            TextButton(
              onPressed: () {
                // Implement logout logic
                Navigator.of(context).pop();
              },
              child: const Text('Logout'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (label == 'Feedback')
            TextButton(
              onPressed: () {
                // Implement feedback submission
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
        ],
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    switch (label) {
      case 'Settings':
        return const Text(
            'Here you can manage your app preferences, notifications, and account settings. \n\n'
                'Options include:\n1. Notification Preferences\n2. Account Management\n3. App Theme\n4. Language Settings\n5. Logout'
        );

      case 'Privacy Policy':
        return const Text(
            '1. We collect user data to improve the app.\n'
                '2. Your data is kept secure.\n'
                '3. No data is shared with third parties.\n'
                '4. You can request to delete your data.\n'
                '5. Usage data is collected for analytics.'
        );

      case 'Terms and Conditions':
        return const Text(
            '1. Use the app responsibly.\n'
                '2. Do not misuse services.\n'
                '3. We reserve the right to modify these terms.\n'
                '4. Accounts violating terms will be suspended.\n'
                '5. Intellectual property belongs to WasteTrack.'
        );

      case 'FAQ':
        return const Text(
            '1. Q: How do I track waste collection?\n   A: Use the Tracking feature.\n\n'
                '2. Q: How do I report an issue?\n   A: Use the Feedback option.\n\n'
                '3. Q: Can I change my account settings?\n   A: Yes, via Settings.'
        );

      case 'About Us':
        return const Text(
            'Waste Management Tracking System aims to provide an efficient way to manage '
                'and track waste collection processes.\n\n'
                'Our mission is to improve waste management logistics, reduce environmental impact, '
                'and enhance community cleanliness. This app integrates mapping, scheduling, and '
                'feedback systems to ensure smooth operations and user satisfaction.'
        );

      case 'Feedback':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide your feedback or report an issue below:'),
            const SizedBox(height: 10),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Type your feedback here...',
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
            SizedBox(height: 5),
            Text('Phone: +94 11 234 5678'),
            SizedBox(height: 5),
            Text('Address: No. 123, Green Street, Colombo, Sri Lanka'),
            SizedBox(height: 10),
            Text(
              'For inquiries, complaints, or suggestions, please reach out to us. '
                  'Our team is available from 8 AM to 6 PM on weekdays.',
            ),
          ],
        );

      default:
        return Text('$label content goes here.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: InkWell(
        onTap: () => _showDialog(context),
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
}