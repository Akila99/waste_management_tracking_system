import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int)? onTabTapped;
  final int currentIndex;

  const MyBottomNavBar({
    Key? key,
    required this.onTabTapped,
    required this.currentIndex,
  }) : super(key: key);

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




// // import 'package:flutter/material.dart';
// //
// // class MyBottomNavBarWithChatbot extends StatelessWidget {
// //   final void Function(int)? onTabTapped;
// //   final int currentIndex;
// //   final VoidCallback onChatbotTap;
// //
// //   const MyBottomNavBarWithChatbot({
// //     Key? key,
// //     required this.onTabTapped,
// //     required this.currentIndex,
// //     required this.onChatbotTap,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Stack(
// //       children: [
// //         // Bottom Navigation Bar
// //         Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Padding(
// //               padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(30),
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     color: const Color(0x8002C84A), // Transparent green
// //                     borderRadius: BorderRadius.circular(30),
// //                   ),
// //                   child: BottomNavigationBar(
// //                     type: BottomNavigationBarType.fixed,
// //                     backgroundColor: Colors.transparent,
// //                     elevation: 0,
// //                     currentIndex: currentIndex,
// //                     onTap: onTabTapped,
// //                     selectedItemColor: Colors.white,
// //                     unselectedItemColor: Colors.white70,
// //                     showSelectedLabels: true,
// //                     showUnselectedLabels: true,
// //                     items: const <BottomNavigationBarItem>[
// //                       BottomNavigationBarItem(
// //                         icon: Icon(Icons.home),
// //                         label: 'Home',
// //                       ),
// //                       BottomNavigationBarItem(
// //                         icon: Icon(Icons.gps_fixed),
// //                         label: 'Tracking',
// //                       ),
// //                       BottomNavigationBarItem(
// //                         icon: Icon(Icons.schedule),
// //                         label: 'Schedule',
// //                       ),
// //                       BottomNavigationBarItem(
// //                         icon: Icon(Icons.more_horiz),
// //                         label: 'More',
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //         // Chatbot Icon
// //         Positioned(
// //           bottom: 80, // Adjust position above the bottom navigation bar
// //           right: 16, // Align towards the right edge
// //           child: GestureDetector(
// //             onTap: onChatbotTap,
// //             child: CircleAvatar(
// //               radius: 30, // Size of the circle
// //               backgroundColor: Colors.green, // Circle background color
// //               child: ClipOval(
// //                 child: Image.asset(
// //                   'assets/images/chatBot.png', // Replace with your image asset path
// //                   fit: BoxFit.cover,
// //                   width: 50, // Width of the image
// //                   height: 50, // Height of the image
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //
// //       ],
// //     );
// //   }
// // }
//
// // import 'package:flutter/material.dart';
// //
// // class MyBottomNavBarWithChatbot extends StatelessWidget {
// //   final void Function(int)? onTabTapped;
// //   final int currentIndex;
// //   final VoidCallback onChatbotTap;
// //
// //   const MyBottomNavBarWithChatbot({
// //     Key? key,
// //     required this.onTabTapped,
// //     required this.currentIndex,
// //     required this.onChatbotTap,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Stack(
// //       children: [
// //         // Bottom Navigation Bar Widget
// //         Positioned.fill(
// //           child: Align(
// //             alignment: Alignment.bottomCenter,
// //             child: BottomNavBar(
// //               currentIndex: currentIndex,
// //               onTabTapped: onTabTapped,
// //             ),
// //           ),
// //         ),
// //
// //         // Chatbot Icon Widget
// //         Positioned(
// //           bottom: 150, // Adjusted position above the BottomNavigationBar
// //           right: 16, // Align towards the right edge
// //           child: ChatbotIcon(
// //             onTap: onChatbotTap,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // // BottomNavigationBar Widget
// // class BottomNavBar extends StatelessWidget {
// //   final void Function(int)? onTabTapped;
// //   final int currentIndex;
// //
// //   const BottomNavBar({
// //     Key? key,
// //     required this.onTabTapped,
// //     required this.currentIndex,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 80), // Space for chatbot icon
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(30),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: const Color(0x8002C84A), // Transparent green
// //             borderRadius: BorderRadius.circular(30),
// //           ),
// //           child: BottomNavigationBar(
// //             type: BottomNavigationBarType.fixed,
// //             backgroundColor: Colors.transparent,
// //             elevation: 0,
// //             currentIndex: currentIndex,
// //             onTap: onTabTapped,
// //             selectedItemColor: Colors.white,
// //             unselectedItemColor: Colors.white70,
// //             showSelectedLabels: true,
// //             showUnselectedLabels: true,
// //             items: const <BottomNavigationBarItem>[
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.home),
// //                 label: 'Home',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.gps_fixed),
// //                 label: 'Tracking',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.schedule),
// //                 label: 'Schedule',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.more_horiz),
// //                 label: 'More',
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Chatbot Icon Widget
// // class ChatbotIcon extends StatelessWidget {
// //   final VoidCallback onTap;
// //
// //   const ChatbotIcon({Key? key, required this.onTap}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: CircleAvatar(
// //         radius: 30, // Size of the circle
// //         backgroundColor: Colors.green, // Circle background color
// //         child: ClipOval(
// //           child: Image.asset(
// //             'assets/images/chatBot.png', // Replace with your image asset path
// //             fit: BoxFit.cover,
// //             width: 50, // Width of the image
// //             height: 50, // Height of the image
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// // import 'package:flutter/material.dart';
// //
// // class MyBottomNavBarWithChatbot extends StatelessWidget {
// //   final void Function(int)? onTabTapped;
// //   final int currentIndex;
// //   final VoidCallback onChatbotTap;
// //
// //   const MyBottomNavBarWithChatbot({
// //     Key? key,
// //     required this.onTabTapped,
// //     required this.currentIndex,
// //     required this.onChatbotTap,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Stack(
// //       children: [
// //         // Bottom Navigation Bar Widget
// //         Positioned.fill(
// //           child: Align(
// //             alignment: Alignment.bottomCenter,
// //             child: BottomNavBar(
// //               currentIndex: currentIndex,
// //               onTabTapped: onTabTapped,
// //             ),
// //           ),
// //         ),
// //
// //         // Chatbot Icon Widget
// //         Positioned(
// //           bottom: 100, // Increased gap between BottomNavBar and Chatbot Icon
// //           right: 16,   // Align towards the right edge
// //           child: ChatbotIcon(
// //             onTap: onChatbotTap,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // // BottomNavigationBar Widget
// // class BottomNavBar extends StatelessWidget {
// //   final void Function(int)? onTabTapped;
// //   final int currentIndex;
// //
// //   const BottomNavBar({
// //     Key? key,
// //     required this.onTabTapped,
// //     required this.currentIndex,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16), // Adjusted for a visible gap between navbar and screen bottom
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(30),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: const Color(0x8002C84A), // Transparent green
// //             borderRadius: BorderRadius.circular(30),
// //           ),
// //           child: BottomNavigationBar(
// //             type: BottomNavigationBarType.fixed,
// //             backgroundColor: Colors.transparent,
// //             elevation: 0,
// //             currentIndex: currentIndex,
// //             onTap: onTabTapped,
// //             selectedItemColor: Colors.white,
// //             unselectedItemColor: Colors.white70,
// //             showSelectedLabels: true,
// //             showUnselectedLabels: true,
// //             items: const <BottomNavigationBarItem>[
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.home),
// //                 label: 'Home',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.gps_fixed),
// //                 label: 'Tracking',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.schedule),
// //                 label: 'Schedule',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.more_horiz),
// //                 label: 'More',
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Chatbot Icon Widget
// // class ChatbotIcon extends StatelessWidget {
// //   final VoidCallback onTap;
// //
// //   const ChatbotIcon({Key? key, required this.onTap}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: CircleAvatar(
// //         radius: 30, // Size of the circle
// //         backgroundColor: Colors.green, // Circle background color
// //         child: ClipOval(
// //           child: Image.asset(
// //             'assets/images/chatBot.png', // Replace with your image asset path
// //             fit: BoxFit.cover,
// //             width: 50, // Width of the image
// //             height: 50, // Height of the image
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
//
// class MyBottomNavBarWithChatbot extends StatefulWidget {
//   final void Function(int)? onTabTapped;
//   final int currentIndex;
//   // final VoidCallback onChatbotTap;
//
//   const MyBottomNavBarWithChatbot({
//     Key? key,
//     required this.onTabTapped,
//     required this.currentIndex,
//     // required this.onChatbotTap,
//   }) : super(key: key);
//
//   @override
//   _MyBottomNavBarWithChatbotState createState() =>
//       _MyBottomNavBarWithChatbotState();
// }
//
// class _MyBottomNavBarWithChatbotState
//     extends State<MyBottomNavBarWithChatbot> {
//   double _chatbotPositionX = 16; // Initial X position
//   double _chatbotPositionY = 100; // Initial Y position
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Bottom Navigation Bar Widget
//         Positioned.fill(
//           child: Align(
//             alignment: Alignment.bottomCenter,
//             child: BottomNavBar(
//               currentIndex: widget.currentIndex,
//               onTabTapped: widget.onTabTapped,
//             ),
//           ),
//         ),
//
//         // Draggable Chatbot Icon Widget
//         // Positioned(
//         //   bottom: _chatbotPositionY, // Use updated Y position
//         //   right: _chatbotPositionX,  // Use updated X position
//         //   child: DraggableChatbotIcon(
//         //     onTap: widget.onChatbotTap,
//         //     onDragUpdate: (details) {
//         //       setState(() {
//         //         // Update the chatbot position while dragging
//         //         _chatbotPositionX = details.localPosition.dx;
//         //         _chatbotPositionY = details.localPosition.dy;
//         //       });
//         //     },
//         //   ),
//         // ),
//       ],
//     );
//   }
// }
//
// // BottomNavigationBar Widget
// class BottomNavBar extends StatelessWidget {
//   final void Function(int)? onTabTapped;
//   final int currentIndex;
//
//   const BottomNavBar({
//     Key? key,
//     required this.onTabTapped,
//     required this.currentIndex,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16), // Space for visible gap between navbar and screen bottom
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(30),
//         child: Container(
//           decoration: BoxDecoration(
//             color: const Color(0x8002C84A), // Transparent green
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             currentIndex: currentIndex,
//             onTap: onTabTapped,
//             selectedItemColor: Colors.white,
//             unselectedItemColor: Colors.white70,
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             items: const <BottomNavigationBarItem>[
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.gps_fixed),
//                 label: 'Tracking',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.schedule),
//                 label: 'Schedule',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.more_horiz),
//                 label: 'More',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Draggable Chatbot Icon Widget
// class DraggableChatbotIcon extends StatelessWidget {
//   final VoidCallback onTap;
//   final Function(DragUpdateDetails) onDragUpdate;
//
//   const DraggableChatbotIcon({
//     Key? key,
//     required this.onTap,
//     required this.onDragUpdate,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Draggable(
//         feedback: Material(
//           color: Colors.transparent,
//           child: CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.green,
//             child: ClipOval(
//               child: Image.asset(
//                 'assets/images/chatBot.png', // Replace with your image asset path
//                 fit: BoxFit.cover,
//                 width: 50,
//                 height: 50,
//               ),
//             ),
//           ),
//         ),
//         childWhenDragging: SizedBox(), // Widget shown when dragging; can be empty or an alternative widget
//         onDragUpdate: onDragUpdate,
//         child: CircleAvatar(
//           radius: 30,
//           backgroundColor: Colors.green,
//           child: ClipOval(
//             child: Image.asset(
//               'assets/images/chatBot.png', // Replace with your image asset path
//               fit: BoxFit.cover,
//               width: 50,
//               height: 50,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//







