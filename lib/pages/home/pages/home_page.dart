// home_page.dart
import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  final List<Map<String, String>> tabs = [
    {'title': 'Home Trash Pickup', 'description': 'We handle all your home trash needs.'},
    {'title': 'Business Trash Pickup', 'description': 'Efficient waste solutions for businesses.'},
    {'title': 'Construction Waste Pickup', 'description': 'Reliable disposal for construction sites.'},
    {'title': 'Recycling Services', 'description': 'Recycle effectively with our services.'},
    {'title': 'Special Waste Pickup', 'description': 'Handling special and hazardous waste.'},
    {'title': 'Bulk Pickup', 'description': 'Convenient solutions for bulk waste.'},
  ];

  final List<Map<String, String>> adTabs = [
    {'title': 'Special Offer 1'},
    {'title': 'Special Offer 2'},
    {'title': 'Special Offer 3'},
    {'title': 'Special Offer 4'},
  ];

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(viewportFraction: 0.85);
    PageController adPageController = PageController(viewportFraction: 0.85);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 500,
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
                      margin: EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
                        onPressed: () {
                          pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      margin: EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                        onPressed: () {
                          pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 250,
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
                      margin: EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.green[700]),
                        onPressed: () {
                          adPageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      margin: EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                        onPressed: () {
                          adPageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
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
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForService(tab['title'] ?? ''),
              size: 80,
              color: Colors.green[700],
            ),
            SizedBox(height: 20),
            Text(
              tab['title']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
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

  IconData _getIconForService(String title) {
    switch (title) {
      case 'Home Trash Pickup':
        return Icons.home;
      case 'Business Trash Pickup':
        return Icons.business;
      case 'Construction Waste Pickup':
        return Icons.construction;
      case 'Recycling Services':
        return Icons.recycling;
      case 'Special Waste Pickup':
        return Icons.warning;
      case 'Bulk Pickup':
        return Icons.local_shipping;
      default:
        return Icons.delete;
    }
  }

  Widget _buildAdTab(BuildContext context, Map<String, String> ad) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Icon(
                Icons.campaign,
                size: 60,
                color: Colors.green[700],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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