// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        print("ios returned");
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCFlnrFjyvReGU2Cpo2tS9itvdImzAdG04',
    appId: '1:922192663569:web:2033921797427b6f2c4db0',
    messagingSenderId: '922192663569',
    projectId: 'mifone-flutter',
    authDomain: 'mifone-flutter.firebaseapp.com',
    storageBucket: 'mifone-flutter.appspot.com',
    measurementId: 'G-2M5GZYBLPL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIZvQS-T8XzGVtammMTCYCioyyiAZoXtU',
    appId: '1:674431547460:android:8b45f2270b4a74d21b2411',
    messagingSenderId: '674431547460',
    projectId: 'mifone-bd1fc',
    storageBucket: 'mifone-bd1fc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAdrB7KghPrtj54JAkuNMj7oxFpJV8dFW0',
    appId: '1:674431547460:ios:5ccbbb6655b6d15c1b2411',
    messagingSenderId: '674431547460',
    projectId: 'mifone-bd1fc',
    storageBucket: 'mifone-bd1fc.appspot.com',
    iosClientId: '674431547460-ql80vjbnodv9ck6b51uc7dnjebeasaou.apps.googleusercontent.com',
    iosBundleId: 'mitek.build.phone.mifone.flutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBB1DBN5ymPKscPWEyE6cVVKPyMJihssB4',
    appId: '1:922192663569:ios:e7df6ecc5fa59e252c4db0',
    messagingSenderId: '922192663569',
    projectId: 'mifone-flutter',
    storageBucket: 'mifone-flutter.appspot.com',
    iosClientId: '922192663569-cqapvocmcrb67nkoof420v8096hqshaj.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterWebrtc.RunnerTests',
  );
}