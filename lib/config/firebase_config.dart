import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  // App principal: Auth, Firestore, Hosting
  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: 'AIzaSyAaPdAuxl9HmG9Bkuxv_yBucsHKaYhCakw',
    authDomain: 'gestasocia.firebaseapp.com',
    projectId: 'gestasocia',
    storageBucket: 'gestasocia.appspot.com',
    messagingSenderId: '706034268275',
    appId: '1:706034268275:web:8d157ac29c51bcd76d9206',
  );

  // App secundaria: SOLO para Storage (otro proyecto)
  static const FirebaseOptions storageOptions = FirebaseOptions(
    apiKey: 'AIzaSyDY_gifFSUNAu28f-P106E0tsVKSaoaJZI',
    authDomain: 'gestasocia-bucket-4b6ea.firebaseapp.com',
    projectId: 'gestasocia-bucket-4b6ea',
    storageBucket: 'gestasocia-bucket-4b6ea.firebasestorage.app',
    messagingSenderId: '584691821183',
    appId: '1:584691821183:web:643f1f53fa6e5c9667ad4a',
  );
}