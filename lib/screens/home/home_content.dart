// lib/screens/home/home_content.dart

import 'package:flutter/material.dart';
import 'package:waste_management_tracking/screens/map/area_selector.dart';

class HomeContent extends StatelessWidget {
  final List<Map<String, String>> services = [
    {
      'title': 'Home Trash Pickup',
      'description': 'We handle all your home trash needs.',
      'icon': 'assets/images/home.png'
    },
    {
      'title': 'Business Trash Pickup',
      'description': 'Efficient waste solutions for businesses.',
      'icon': 'assets/images/business.png'
    },
    {
      'title': 'Construction Waste Pickup',
      'description': 'Reliable disposal for construction sites.',
      'icon': 'assets/images/construction.png'
    },
    {
      'title': 'Recycling Services',
      'description': 'Recycle effectively with our services.',
      'icon': 'assets/images/recycle.png'
    },
    {
      'title': 'Special Waste Pickup',
      'description': 'Handling special and hazardous waste.',
      'icon': 'assets/images/special.png'
    },
    {
      'title': 'Bulk Pickup',
      'description': 'Convenient solutions for bulk waste.',
      'icon': 'assets/images/bulk.png'
    },
  ];

  final List<Map<String, String>> promotions = [
    {'image': 'assets/images/ad1.jpg', 'title': 'Special Offer 1'},
    {'image': 'assets/images/ad2.jpg', 'title': 'Special Offer 2'},
    {'image': 'assets/images/ad3.jpg', 'title': 'Special Offer 3'},
    {'image': 'assets/images/ad4.jpg', 'title': 'Special Offer 4'},
  ];

  @override
  Widget build(BuildContext context) {
    PageController servicesController = PageController(viewportFraction: 0.8);
    PageController promotionsController = PageController(viewportFraction: 0.8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Services Carousel
          Container(
            height: 500,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: servicesController,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(services[index]);
                  },
                ),
                _buildNavigationArrows(servicesController),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tracking Card
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

          const SizedBox(height: 24),

          // Promotions Carousel
          Container(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: promotionsController,
                  itemCount: promotions.length,
                  itemBuilder: (context, index) {
                    return _buildPromotionCard(promotions[index]);
                  },
                ),
                _buildNavigationArrows(promotionsController),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent Updates Section
          const Text(
            'Recent Updates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildServiceCard(Map<String, String> service) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            service['icon']!,
            height: 180,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.image, size: 180, color: Colors.grey);
            },
          ),
          const SizedBox(height: 20),
          Text(
            service['title']!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              service['description']!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(Map<String, String> promotion) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              promotion['image']!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, size: 200, color: Colors.grey);
              },
            ),
          ),
          const SizedBox(height: 15),
          Text(
            promotion['title']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationArrows(PageController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }
}