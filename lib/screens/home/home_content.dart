import 'package:flutter/material.dart';
import 'package:waste_management_tracking/screens/map/area_selector.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AreaSelector()),
                );
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
          // Add your recent updates list here
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