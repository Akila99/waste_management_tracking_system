import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  final String initialLabel;

  // Constructor to accept the initial label
  MoreScreen({this.initialLabel = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: GridView.count(
        padding: EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          MoreOption(icon: Icons.settings, label: 'Settings', isSelected: initialLabel == 'Settings'),
          MoreOption(icon: Icons.privacy_tip, label: 'Privacy Policy', isSelected: initialLabel == 'Privacy Policy'),
          MoreOption(icon: Icons.description, label: 'Terms and Conditions', isSelected: initialLabel == 'Terms and Conditions'),
          MoreOption(icon: Icons.help_outline, label: 'FAQ', isSelected: initialLabel == 'FAQ'),
          MoreOption(icon: Icons.info, label: 'About Us', isSelected: initialLabel == 'About Us'),
          MoreOption(icon: Icons.feedback, label: 'Feedback', isSelected: initialLabel == 'Feedback'),
          MoreOption(icon: Icons.contact_mail, label: 'Contact Us', isSelected: initialLabel == 'Contact Us'),
        ],
      ),
    );
  }
}


class MoreOption extends StatelessWidget {
final IconData icon;
final String label;
final bool isSelected; // New parameter to check if it's the selected label

MoreOption({required this.icon, required this.label, this.isSelected = false});

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      content: _getContent(context),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

Widget _getContent(BuildContext context) {
  // Same content as before, based on label
  switch (label) {
    case 'Settings':
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableOption(context, 'Notification Preferences'),
          SizedBox(height: 10),
          _buildClickableOption(context, 'Account Management'),
          SizedBox(height: 10),
          _buildClickableOption(context, 'App Theme'),
          SizedBox(height: 10),
          _buildClickableOption(context, 'Language Settings'),
        ],
      );

  // Other cases remain unchanged
    case 'Privacy Policy':
      return Text('1. We collect user data to improve the app.\n2. Your data is kept secure.\n3. No data is shared with third parties.\n4. You can request to delete your data.\n5. Usage data is collected for analytics.');
    case 'Terms and Conditions':
      return Text('1. Use the app responsibly.\n2. Do not misuse services.\n3. We reserve the right to modify these terms.\n4. Accounts violating terms will be suspended.\n5. Intellectual property belongs to WasteTrack.');
    case 'FAQ':
      return Text('1. Q: How do I track waste collection?\n   A: Use the Tracking feature.\n\n'
          '2. Q: How do I report an issue?\n   A: Use the Feedback option.\n\n'
          '3. Q: Can I change my account settings?\n   A: Yes, via Settings.');
    case 'About Us':
      return Text('Waste Management Tracking System aims to provide an efficient way to manage and track waste collection processes.\n\n'
          'Our mission is to improve waste management logistics, reduce environmental impact, and enhance community cleanliness. This app integrates mapping, scheduling, and feedback systems to ensure smooth operations and user satisfaction.');
    case 'Feedback':
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Please provide your feedback or report an issue below:'),
          SizedBox(height: 10),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type your feedback here...',
            ),
          ),
        ],
      );
    case 'Contact Us':
      return Column(
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

Widget _buildClickableOption(BuildContext context, String optionLabel) {
  return GestureDetector(
    onTap: () => _showUnderConstructionDialog(context),
    child: Text(
      optionLabel,
      style: TextStyle(
        color: Colors.green.shade700,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

void _showUnderConstructionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Coming Soon!', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text('This setting is under construction. Stay tuned for future updates!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  // Apply green color only to specified labels
  final bool isSpecialButton = [
    'Settings',
    'Privacy Policy',
    'Terms and Conditions',
    'FAQ',
    'About Us',
    'Feedback',
    'Contact Us'
  ].contains(label);

  return Card(
    color: Colors.green[50],
    child: InkWell(
      onTap: () => _showDialog(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.green),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : null, // Highlight selected option
            ),
          ),
        ],
      ),
    ),
  );
}
}


/*
class MoreOption extends StatelessWidget {
  final IconData icon;
  final String label;

  MoreOption({required this.icon, required this.label});

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        content: _getContent(context),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    switch (label) {
      case 'Settings':
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClickableOption(context, 'Notification Preferences'),
            SizedBox(height: 10),
            _buildClickableOption(context, 'Account Management'),
            SizedBox(height: 10),
            _buildClickableOption(context, 'App Theme'),
            SizedBox(height: 10),
            _buildClickableOption(context, 'Language Settings'),
          ],
        );

      case 'Privacy Policy':
        return Text('1. We collect user data to improve the app.\n2. Your data is kept secure.\n3. No data is shared with third parties.\n4. You can request to delete your data.\n5. Usage data is collected for analytics.');

      case 'Terms and Conditions':
        return Text('1. Use the app responsibly.\n2. Do not misuse services.\n3. We reserve the right to modify these terms.\n4. Accounts violating terms will be suspended.\n5. Intellectual property belongs to WasteTrack.');

      case 'FAQ':
        return Text('1. Q: How do I track waste collection?\n   A: Use the Tracking feature.\n\n'
            '2. Q: How do I report an issue?\n   A: Use the Feedback option.\n\n'
            '3. Q: Can I change my account settings?\n   A: Yes, via Settings.');

      case 'About Us':
        return Text('Waste Management Tracking System aims to provide an efficient way to manage and track waste collection processes.\n\n'
            'Our mission is to improve waste management logistics, reduce environmental impact, and enhance community cleanliness. This app integrates mapping, scheduling, and feedback systems to ensure smooth operations and user satisfaction.');

      case 'Feedback':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide your feedback or report an issue below:'),
            SizedBox(height: 10),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your feedback here...',
              ),
            ),
          ],
        );

      case 'Contact Us':
        return Column(
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

  // Helper method to create clickable options
  Widget _buildClickableOption(BuildContext context, String optionLabel) {
    return GestureDetector(
      onTap: () => _showUnderConstructionDialog(context),
      child: Text(
        optionLabel,
        style: TextStyle(
          color: Colors.green.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Function to show "Under construction" popup
  void _showUnderConstructionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('This setting is under construction. Stay tuned for future updates!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply green color only to specified labels
    final bool isSpecialButton = [
      'Settings',
      'Privacy Policy',
      'Terms and Conditions',
      'FAQ',
      'About Us',
      'Feedback',
      'Contact Us'
    ].contains(label);

    return Card(
      color: Colors.green[50],
      child: InkWell(
        onTap: () => _showDialog(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSpecialButton ? Colors.green : null, // Apply green if it's a special button
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
