import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class ShowMessage {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotification() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    var androidInitializationSettings =
    const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
          // print("Route");
          // Get.toNamed(AppRoute.notification);
        });
  }

  // Refactored method: now takes String name (title) and String texts (body)
  static Future<void> showNotification(String name, String texts) async {
    // Generate a unique channel ID (good practice, though not strictly required
    // if you only use one channel with a fixed ID)
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        "High Importance Notification",
        importance: Importance.max);

    // 1. Android Notification Details
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      // Using the generated channel ID
        channel.id,
        channel.name,
        channelDescription: "your channel Description",
        importance: Importance.high,
        priority: Priority.high,
        ticker: "ticker");

    // 2. iOS/Darwin Notification Details
    DarwinNotificationDetails darwinNotificationDetails =
    const DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    // 3. Platform-Agnostic Notification Details
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    // 4. Showing the Notification
    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        // Use a fixed ID or generate a unique one if needed. Using 0 for simplicity.
          0,
          // 'name' is used as the notification title
          name,
          // 'texts' is used as the notification body
          texts,
          notificationDetails);
    });
  }
}

// Example of how to call the new method:
// NotificationService.showNotification("New Message Alert", "You have a new unread message from John Doe.");