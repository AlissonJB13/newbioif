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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCv3QpVCFHa7Q4TDHyXdr8TBDMAlY3ZqYk',
    appId: '1:342696241074:android:b87b08b3a0122506c526ab',
    messagingSenderId: '342696241074',
    projectId: 'bioif-39a18',
    storageBucket: 'bioif-39a18.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlYrDs90Hsgz7vRIeM8JE-ELsC9-B-9Yc',
    appId: '1:342696241074:ios:ee1a4d2bbc5678e4c526ab',
    messagingSenderId: '342696241074',
    projectId: 'bioif-39a18',
    storageBucket: 'bioif-39a18.appspot.com',
    androidClientId: '342696241074-48pduinkpgcta4h2rk521rnhjt01uhhq.apps.googleusercontent.com',
    iosClientId: '342696241074-qrclplo6547lq8fe363dstmn7dlcfb8h.apps.googleusercontent.com',
    iosBundleId: 'br.com.bioif.bioIf',
  );
}
