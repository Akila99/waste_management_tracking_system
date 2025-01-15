// home_page.dart
import 'package:flutter/material.dart';
import '../components/home_drawer.dart';

class HomeContent extends StatelessWidget {
  HomeContent({Key? key}) : super(key: key);

  final List<Map<String, String>> tabs = [
    {
      'title': 'Home Trash Pickup',
      'description': 'We handle all your home trash needs.',
      'image': 'assets/images/home.png'
    },
    {
      'title': 'Business Trash Pickup',
      'description': 'Efficient waste solutions for businesses.',
      'image': 'assets/images/business.png'
    },
    {
      'title': 'Construction Waste Pickup',
      'description': 'Reliable disposal for construction sites.',
      'image': 'assets/images/construction.png'
    },
    {
      'title': 'Recycling Services',
      'description': 'Recycle effectively with our services.',
      'image': 'assets/images/recycle.png'
    },
    {
      'title': 'Special Waste Pickup',
      'description': 'Handling special and hazardous waste.',
      'image': 'assets/images/special.png'
    },
    {
      'title': 'Bulk Pickup',
      'description': 'Convenient solutions for bulk waste.',
      'image': 'assets/images/bulk.png'
    },
  ];

  final List<Map<String, String>> adTabs = [
    {'title': 'Special Offer 1', 'image': 'assets/images/ad1.jpg'},
    {'title': 'Special Offer 2', 'image': 'assets/images/ad2.jpg'},
    {'title': 'Special Offer 3', 'image': 'assets/images/ad3.jpg'},
    {'title': 'Special Offer 4', 'image': 'assets/images/stable.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(viewportFraction: 0.85);
    PageController adPageController = PageController(viewportFraction: 0.85);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 600,
              color: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      return _buildTab(context, tabs[index]);
                    },
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Track Waste Collection Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.green[700],
                    size: 28,
                  ),
                  title: const Text(
                    'Track Waste Collection',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'View real time tracking',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    final HomeScreenState? homeState =
                    context.findAncestorStateOfType<HomeScreenState>();
                    if (homeState != null) {
                      homeState.navigateBottomBar(1);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Recent Updates Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Updates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.notifications_active, color: Colors.green[700]),
                          ),
                          title: const Text(
                            'New Feature Added',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Real-time waste collection tracking is now available'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.system_update, color: Colors.green[700]),
                          ),
                          title: const Text(
                            'System Update',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Performance improvements and bug fixes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 300,
              color: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: adPageController,
                    itemCount: adTabs.length,
                    itemBuilder: (context, index) {
                      return _buildAdTab(context, adTabs[index]);
                    },
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
                        onPressed: () {
                          adPageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                        onPressed: () {
                          adPageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, Map<String, String> tab) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200, // Increased height for bigger images
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                tab['image']!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tab['title']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              tab['description']!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdTab(BuildContext context, Map<String, String> ad) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 200, // Increased height for bigger images
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[100],
              ),
              child: Image.asset(
                ad['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.campaign,
                    size: 60,
                    color: Colors.green[700],
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Text(
              ad['title']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}