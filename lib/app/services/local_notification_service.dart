import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  static Future<void> Function(String? payload)? onNotificationTap;

  static Future<void> init({bool requestPermission = true}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await notification.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    if (requestPermission) {
      await notification
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'rideon_notification',
      'RideOn Notification',
      channelDescription: 'Reminder komponen kendaraan',
      importance: Importance.max,
      priority: Priority.high,
    );

    await notification.show(
      id,
      title,
      body,
      const NotificationDetails(android: android),
      payload: payload,
    );
  }

  static Future<void> cancel(int id) => notification.cancel(id);

  static Future<String?> getLaunchPayload() async {
    final details = await notification.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }
}
