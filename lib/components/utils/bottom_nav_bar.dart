import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int)? onTabTapped;
  final int currentIndex;

  const MyBottomNavBar({
    Key? key,
    required this.onTabTapped,
    required this.currentIndex,
  }) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(30),
  //       child: Theme(
  //         data: Theme.of(context).copyWith(
  //           canvasColor: Colors.transparent,
  //         ),
  //         child: BottomNavigationBar(
  //           type: BottomNavigationBarType.fixed,
  //           backgroundColor: const Color(0xFF4CAF50),
  //           elevation: 0,
  //           currentIndex: currentIndex,
  //           onTap: onTabTapped,
  //           selectedItemColor: Colors.white,
  //           unselectedItemColor: Colors.white70,
  //           showSelectedLabels: true,
  //           showUnselectedLabels: true,
  //           items: const <BottomNavigationBarItem>[
  //             BottomNavigationBarItem(
  //               icon: Icon(Icons.home),
  //               label: 'Home',
  //             ),
  //             BottomNavigationBarItem(
  //               icon: Icon(Icons.gps_fixed),
  //               label: 'Tracking',
  //             ),
  //             BottomNavigationBarItem(
  //               icon: Icon(Icons.schedule),
  //               label: 'Schedule',
  //             ),
  //             BottomNavigationBarItem(
  //               icon: Icon(Icons.more_horiz),
  //               label: 'More',
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0x8002C84A), // Add transparency (50% opacity)
            borderRadius: BorderRadius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, // Set the background to transparent
            elevation: 0,
            currentIndex: currentIndex,
            onTap: onTabTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: true,
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
      ),
    );
  }
}


