import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
Center(
        child: Text(
          'Ads',
          style: TextStyle(fontSize: 50),
        ),
      ),Center(
        child: Text(
          'Tracking',
          style: TextStyle(fontSize: 50),
      ),
    ),Center(
        child: Text(
          'Schedule',
          style: TextStyle(fontSize: 50),
      ),
    ),Center(
        child: Text(
          'More',
          style: TextStyle(fontSize: 50),
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          type: BottomNavigationBarType.fixed,
          items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ]),
    );
  }
}


