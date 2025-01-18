import 'package:flutter/material.dart';
import '../components/home_drawer.dart';
import 'package:waste_management_tracking/components/services/add_link.dart';

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
    {'title': 'Colombo Municipal Council ', 'image': 'assets/images/ad1.jpg', 'link': 'https://www.colombo.mc.gov.lk/'},
    {'title': 'KFC Offers', 'image': 'assets/images/ad2.jpg', 'link': 'https://www.kfc.lk/'},
    {'title': 'View Online News', 'image': 'assets/images/ad3.jpeg', 'link': 'https://www.dailymirror.lk/'},
    {'title': 'Daraz Offers', 'image': 'assets/images/stable.jpeg', 'link': 'https://www.daraz.lk/#?'},
  ];

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> pageIndex = ValueNotifier<int>(0);
    ValueNotifier<int> adPageIndex = ValueNotifier<int>(0);

    PageController pageController = PageController(viewportFraction: 0.85);
    PageController adPageController = PageController(viewportFraction: 0.85);

    void updatePageIndex(PageController controller,
        ValueNotifier<int> notifier) {
      controller.addListener(() {
        notifier.value = controller.page?.round() ?? 0;
      });
    }

    updatePageIndex(pageController, pageIndex);
    updatePageIndex(adPageController, adPageIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Tabs Section
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
                  ValueListenableBuilder<int>(
                    valueListenable: pageIndex,
                    builder: (context, value, _) {
                      return Visibility(
                        visible: value > 0,
                        child: Positioned(
                          left: 0,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios,
                                color: Colors.green[700]),
                            onPressed: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: pageIndex,
                    builder: (context, value, _) {
                      return Visibility(
                        visible: value < tabs.length - 1,
                        child: Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios,
                                color: Colors.green[700]),
                            onPressed: () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      );
                    },
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
                    'View real-time tracking',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    // Navigation logic here
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
                            child: Icon(Icons.notifications_active,
                                color: Colors.green[700]),
                          ),
                          title: const Text(
                            'New Feature Added',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                              'Real-time waste collection tracking is now available'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                                Icons.system_update, color: Colors.green[700]),
                          ),
                          title: const Text(
                            'System Update',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                              'Performance improvements and bug fixes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ad Tabs Section
            Container(
              height: 300,
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
                  ValueListenableBuilder<int>(
                    valueListenable: adPageIndex,
                    builder: (context, value, _) {
                      return Visibility(
                        visible: value > 0,
                        child: Positioned(
                          left: 0,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios,
                                color: Colors.green[700]),
                            onPressed: () {
                              adPageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: adPageIndex,
                    builder: (context, value, _) {
                      return Visibility(
                        visible: value < adTabs.length - 1,
                        child: Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios,
                                color: Colors.green[700]),
                            onPressed: () {
                              adPageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 70), // Changed from 80 to 40 (50% reduction)
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, Map<String, String> tab) {
    return GestureDetector(
      onTap: () {
        // Show the popup dialog when the tab is clicked
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Coming Soon!"),
              content: Text("Special services are coming soon!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 4,
        color: Colors.lightBlue[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180, // Constrained height for image
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
            const SizedBox(height: 10),
            Text(
              tab['title']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                tab['description']!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdTab(BuildContext context, Map<String, String> ad) {
    return GestureDetector(
      onTap: () {
        showAdDialog(
          context,
          ad['title']!,
          ad['link']!, // Pass the specific link for this ad
        );
      },
      child: Card(
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
                height: 200,
                width: double.infinity,
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
          ],
        ),
      ),
    );
  }
}
