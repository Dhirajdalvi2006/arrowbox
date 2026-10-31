// File generated for FlutterFire configuration.
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDxO7uRIT_OO1-QGmYwil_OcZicVxB5a_g',
    appId: '1:1083971733030:web:71feea0c1ea3c1000ec8e7',
    messagingSenderId: '1083971733030',
    projectId: 'arrowbox-f7fae',
    authDomain: 'arrowbox-f7fae.firebaseapp.com',
    storageBucket: 'arrowbox-f7fae.firebasestorage.app',
    measurementId: 'G-BPM43C51YK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGlx9ZaoMQusFgJoYlH0X8ZrE7hE0g23w',
    appId: '1:1083971733030:android:1b731bf945bc76710ec8e7',
    messagingSenderId: '1083971733030',
    projectId: 'arrowbox-f7fae',
    storageBucket: 'arrowbox-f7fae.firebasestorage.app',
  );
}
