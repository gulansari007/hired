import 'dart:math'; // ✅ The correct import for math operations
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices {
  static Future<void> showNotification() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.requestPermission();
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen((message) {
        print(
          'Received a message in the foreground: ${message.notification?.title}',
        );
      });
      //
      print('User granted permission');
      // You can also handle the notification here if needed,
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('${message.notification?.title} was received in the background');
}
