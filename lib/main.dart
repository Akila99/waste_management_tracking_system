// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:waste_management_tracking/pages/home/components/home_drawer.dart';
// import 'firebase_options.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
//
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   try {
//     await FirebaseAppCheck.instance.activate(
//       // Update this recaptcha key with your friend's key
//       webProvider: ReCaptchaV3Provider('6LeXXLUqAAAAAAoEMdZjKT0Ub1xbZFcEHK184d9m'),
//       androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
//       appleProvider: AppleProvider.appAttest,
//     );
//   } catch (e) {
//     print('Failed to activate App Check: $e');
//   }
//
//   runApp(WasteManagementApp());
// }
//
// class WasteManagementApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Waste Management Tracking System',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         primaryColor: const Color(0xFF2E7D32), // Dark green
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF2E7D32),
//           secondary: const Color(0xFF66BB6A), // Lighter green
//           tertiary: const Color(0xFFFFC107), // Amber for accent
//           background: const Color(0xFFF5F5F5), // Light gray background
//         ),
//         scaffoldBackgroundColor: const Color(0xFFF5F5F5),
//         cardTheme: CardTheme(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           color: Colors.white,
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             elevation: 2,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             backgroundColor: const Color(0xFF2E7D32),
//             foregroundColor: Colors.white,
//           ),
//         ),
//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(
//             foregroundColor: const Color(0xFF2E7D32),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//         ),
//         appBarTheme: const AppBarTheme(
//           elevation: 0,
//           backgroundColor: Color(0xFF2E7D32),
//           foregroundColor: Colors.white,
//           centerTitle: true,
//         ),
//         iconTheme: const IconThemeData(
//           color: Color(0xFF2E7D32),
//         ),
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waste_management_tracking/pages/home/components/home_drawer.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';  // Import Firebase Remote Config
import 'package:package_info_plus/package_info_plus.dart';  // To get the current app version
import 'services/remote_config_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('6LeXXLUqAAAAAAoEMdZjKT0Ub1xbZFcEHK184d9m'),
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  } catch (e) {
    print('Failed to activate App Check: $e');
  }

  runApp(WasteManagementApp());
}

class WasteManagementApp extends StatefulWidget {
  @override
  _WasteManagementAppState createState() => _WasteManagementAppState();
}

class _WasteManagementAppState extends State<WasteManagementApp> {
  String? encryptionKey;
  bool? isMaintenanceMode;
  int? minSupportedVersion;

  @override
  void initState() {
    super.initState();
    _fetchRemoteConfig();
  }

  // Fetch Remote Config values
  Future<void> _fetchRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // Fetch and activate Remote Config values
      await remoteConfig.fetch();
      await remoteConfig.activate();

      // Fetch the parameters
      setState(() {
        encryptionKey = remoteConfig.getString('encryption_key');
        isMaintenanceMode = remoteConfig.getBool('maintenance_mode');
        minSupportedVersion = remoteConfig.getInt('min_supported_version');
      });

      // Check if the app is in maintenance mode
      if (isMaintenanceMode == true) {
        _showMaintenanceDialog();
      }

      // Check if the app version is supported
      _checkAppVersion();
    } catch (e) {
      print("Error fetching remote config: $e");
    }
  }

  // Check if the app version is compatible
  Future<void> _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    if (minSupportedVersion != null) {
      // Compare the current app version with the min supported version
      if (currentVersion.compareTo(minSupportedVersion.toString()) < 0) {
        _showUpdateDialog();
      }
    }
  }

  // Show Maintenance Mode Dialog
  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Maintenance Mode'),
          content: const Text('The app is currently under maintenance. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show Update Required Dialog
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Required'),
          content: const Text('Please update the app to the latest version to continue using it.'),
          actions: [
            TextButton(
              onPressed: () {
                // Redirect to app store or update page
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Management Tracking System',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32), // Dark green
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          secondary: const Color(0xFF66BB6A), // Lighter green
          tertiary: const Color(0xFFFFC107), // Amber for accent
          background: const Color(0xFFF5F5F5), // Light gray background
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: HomeScreen(),
    );
  }
}





