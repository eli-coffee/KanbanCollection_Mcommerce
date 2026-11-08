
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
    
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
    apiKey: 'AIzaSyC6Z8T77c8nkVBbx2q11haJdxFZAxCagAY',
    appId: '1:494581914573:web:2733d33db44e184bb00284',
    messagingSenderId: '494581914573',
    projectId: 'integration-system-df09e',
    authDomain: 'integration-system-df09e.firebaseapp.com',
    databaseURL: 'https://integration-system-df09e-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'integration-system-df09e.firebasestorage.app',
    measurementId: 'G-S38X7T89YS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdPqslWlXNPFtAMwJbkn2sJkkUlGn-3d0',
    appId: '1:494581914573:android:3de6f4d02a11ec4eb00284',
    messagingSenderId: '494581914573',
    projectId: 'integration-system-df09e',
    databaseURL: 'https://integration-system-df09e-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'integration-system-df09e.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFvMyfNl-Ol307sJzUdHSnbE7XsfDO97U',
    appId: '1:494581914573:ios:0602cda025c5b4ccb00284',
    messagingSenderId: '494581914573',
    projectId: 'integration-system-df09e',
    databaseURL: 'https://integration-system-df09e-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'integration-system-df09e.firebasestorage.app',
    iosBundleId: 'com.example.finalsProject',
  );
}
