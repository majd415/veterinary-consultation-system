// ignore_for_file: type=lint, lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAkyOHmpt6_BwWrVui4uGSMlRgpk8nZHhQ',
    appId: '1:510700126849:web:7df237173120550ed24380',
    messagingSenderId: '510700126849',
    projectId: 'dog-vet-chat',
    authDomain: 'dog-vet-chat.firebaseapp.com',
    storageBucket: 'dog-vet-chat.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALHvSxYQ3io0hZvtoEL3SdUcE3QGoNNV0',
    appId: '1:510700126849:android:9ce8dc46d405d1b8d24380',
    messagingSenderId: '510700126849',
    projectId: 'dog-vet-chat',
    storageBucket: 'dog-vet-chat.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrVj7rnzWxTrcIy9AMrsw9PKm16n26aMY',
    appId: '1:510700126849:ios:64bb2e07dc0f4f8dd24380',
    messagingSenderId: '510700126849',
    projectId: 'dog-vet-chat',
    storageBucket: 'dog-vet-chat.firebasestorage.app',
    iosBundleId: 'com.example.dogMarket',
  );
}
