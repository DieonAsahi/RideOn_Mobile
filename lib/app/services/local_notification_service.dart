import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await notification.initialize(settings);

    await notification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'motocare_notification',
      'MotoCare Notification',
      channelDescription: 'Reminder komponen kendaraan',
      importance: Importance.max,
      priority: Priority.high,
    );

    await notification.show(
      1,
      title,
      body,
      const NotificationDetails(android: android),
    );
  }
}