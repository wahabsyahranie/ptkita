import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_kita/core/app_router.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission (Android 13+ & iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Subscribe topics
  await FirebaseMessaging.instance.subscribeToTopic("maintenance");
  await FirebaseMessaging.instance.subscribeToTopic("stock");

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print("Foreground message received: ${message.notification?.title}");
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PT Kita",
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: MyColors.secondary),
      ),
      home: const AppRouter(),
    );
  }
}
