import 'package:flutter/material.dart';

void main() {
  runApp(LoadingAnimationApp());
}

class LoadingAnimationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: BlinkingTruck(),
      ),
    );
  }
}

class BlinkingTruck extends StatefulWidget {
  @override
  _BlinkingTruckState createState() => _BlinkingTruckState();
}

class _BlinkingTruckState extends State<BlinkingTruck> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true); // Blinking effect

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Image.asset(
        'assets/truck.png',
        width: 100,
        height: 100,
      ),
    );
  }
}
