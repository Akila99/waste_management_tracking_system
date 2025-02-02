// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBK2MtXpwxKdwUvbONouh4ZmsJmSV3J8sY',
    appId: '1:190720782773:web:eb71e2a6c4dbf5f869a9fc',
    messagingSenderId: '190720782773',
    projectId: 'waste-management-tracking',
    authDomain: 'waste-management-tracking.firebaseapp.com',
    storageBucket: 'waste-management-tracking.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_emhdfAJ4jbK6hLMH1vpr6R9oyH7Dn_E',
    appId: '1:190720782773:android:676197f7ace9242d69a9fc',
    messagingSenderId: '190720782773',
    projectId: 'waste-management-tracking',
    storageBucket: 'waste-management-tracking.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnLRjIVOYGGt1N5nU99ztC_VlLskVcxoc',
    appId: '1:190720782773:ios:bbd845987a47ad3669a9fc',
    messagingSenderId: '190720782773',
    projectId: 'waste-management-tracking',
    storageBucket: 'waste-management-tracking.firebasestorage.app',
    iosBundleId: 'com.example.wastet',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAnLRjIVOYGGt1N5nU99ztC_VlLskVcxoc',
    appId: '1:190720782773:ios:bbd845987a47ad3669a9fc',
    messagingSenderId: '190720782773',
    projectId: 'waste-management-tracking',
    storageBucket: 'waste-management-tracking.firebasestorage.app',
    iosBundleId: 'com.example.wastet',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBK2MtXpwxKdwUvbONouh4ZmsJmSV3J8sY',
    appId: '1:190720782773:web:fd27f4e1fde3559169a9fc',
    messagingSenderId: '190720782773',
    projectId: 'waste-management-tracking',
    authDomain: 'waste-management-tracking.firebaseapp.com',
    storageBucket: 'waste-management-tracking.firebasestorage.app',
  );
}