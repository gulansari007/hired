import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

class NotificationController extends GetxController {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  var obj = Hive.box('myBox');

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  void _initNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void showNotification({
    required int id,
    required String title,
    required String body,
  }) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    flutterLocalNotificationsPlugin.show(id, title, body, platformDetails);
  }

  ////
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RxList<String> notifications = <String>[].obs;

  void initLocalNotification() {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    _localNotifications.initialize(initSettings);
  }

  // fiebase cloud messaging
  void initFCM() async {
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        String title = message.notification?.title ?? "No Title";
        String body = message.notification?.body ?? "No Body";

        String fullMessage = "$title: $body";

        notifications.insert(0, fullMessage);

        // Save and show notification
        notifications.insert(0, "$title: $body");
        List<String> existing =
            obj.get('notifications', defaultValue: [])!.cast<String>();
        existing.insert(0, fullMessage);
        obj.put('notifications', existing);

        _showLocalNotification(title, body);
      });
    }
  }

  void _showLocalNotification(String title, String body) {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  /// Call this method if you want to trigger a sample local notification
  void sendTestNotification() {
    const title = "Test Notification";
    const body = "This is a test notification";
    notifications.insert(0, "$title: $body");
    _showLocalNotification(title, body);
  }
}
