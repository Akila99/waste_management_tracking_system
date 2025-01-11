import 'package:flutter/material.dart';


class HomeContent extends StatelessWidget {
  final List<Map<String, String>> tabs = [
    {'title': 'Home Trash Pickup', 'description': 'We handle all your home trash needs.', 'icon': 'assets/homee.png'},
    {'title': 'Business Trash Pickup', 'description': 'Efficient waste solutions for businesses.', 'icon': 'assets/business.png'},
    {'title': 'Construction Waste Pickup', 'description': 'Reliable disposal for construction sites.', 'icon': 'assets/construction.png'},
    {'title': 'Recycling Services', 'description': 'Recycle effectively with our services.', 'icon': 'assets/recycle.png'},
    {'title': 'Special Waste Pickup', 'description': 'Handling special and hazardous waste.', 'icon': 'assets/special.png'},
    {'title': 'Bulk Pickup', 'description': 'Convenient solutions for bulk waste.', 'icon': 'assets/bulk.png'},
  ];

  final List<Map<String, String>> adTabs = [
    {'image': 'assets/ad1.jpg', 'title': 'Special Offer 1'},
    {'image': 'assets/ad2.jpg', 'title': 'Special Offer 2'},
    {'image': 'assets/ad3.jpg', 'title': 'Special Offer 3'},
    {'image': 'assets/stable.jpg', 'title': 'Special Offer 4'},
  ];

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(viewportFraction: 0.8);
    PageController adPageController = PageController(viewportFraction: 0.8);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 550, // Increased by 50% from 450 to 675
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
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300, // Reduced from 300 to 250
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
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      adPageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      adPageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),SizedBox(height: 60),
        ],
      ),
    );
  }


  Widget _buildTab(BuildContext context, Map<String, String> tab) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.blue[50],
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            tab['icon']!,
            height: 180,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.image, size: 180, color: Colors.grey);
            },
          ),
          SizedBox(height: 20),
          Text(
            tab['title']!,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              tab['description']!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdTab(BuildContext context, Map<String, String> ad) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              ad['image']!,
              height: 180, // Reduced image height
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image, size: 200, color: Colors.grey);
              },
            ),
          ),
          SizedBox(height: 15),
          Text(
            ad['title']!,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}