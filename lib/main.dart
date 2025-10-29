import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hired/controllers/homeController.dart';
import 'package:hired/controllers/internetController.dart';
import 'package:hired/controllers/settingController.dart';
import 'package:hired/firebase_options.dart';
import 'package:hired/services/notification_services.dart';
import 'package:hired/views/localization/language_screen.dart';
import 'package:hired/views/notifications/notification.dart';
import 'package:hired/views/screens/splash_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  // timeago
  timeago.setLocaleMessages('short', ShortMessages());
  // firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // notifcations
  await NotificationServices.showNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Show incoming call screen or local notification
  });
  //
  await LocalNotification.init();

  // hive
  Directory appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  await Hive.openBox('myBox');

  // google ads
  MobileAds.instance.initialize();
  // internet
  Get.put(InternetController());
  // Listen for FCM token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': newToken,
      });
    }
  });
  //

  // get token
  // if (FirebaseAuth.instance.currentUser != null) {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   if (token != null) {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser!.uid)
  //         .update({'fcmToken': token});
  //   }
  // }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final settingsController = Get.put(SettingsController());
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // theme
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode:
          settingsController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,

      translations: AppTranslations(),
      locale: const Locale('en', 'US'), // default
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('es', 'ES'),
        const Locale('hi'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      fallbackLocale: const Locale('en', 'US'),

      home: SplashScreen(),
    );
  }
}
