import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/more_page.dart';
import '../pages/schedule_page.dart';
import '../pages/tracking_page.dart';
import 'login.dart';
import 'bottom_nav_bar.dart';



class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    HomeContent(),
    TrackingScreen(),
    SchedulePage(),
    MoreScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showProfileDialog() {
    String name = "";
    String city = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'City'),
                onChanged: (value) {
                  city = value;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle profile picture editing
                },
                child: Text('Edit Profile Picture'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save user info
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavBar(
          onTabTapped: _onTabTapped,
          currentIndex: _currentIndex
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title: Text('Hello! User'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: _showProfileDialog,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Sign Up'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      extendBody: true,  // Make body extend behind bottom navigation bar
      /*bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            items: const <BottomNavigationBarItem>[
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
        ),
      ),*/
    );
  }
}

/*class HomeContent extends StatelessWidget {
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
}*/