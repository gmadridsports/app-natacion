import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
    init();
  }

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const InitializationSettings initializationSettings =
      InitializationSettings(
    android: AndroidInitializationSettings('ic_launcher'),
    iOS: DarwinInitializationSettings(
        // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true),
  );

  Future<void> init() async {
    notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> sendNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('gmadrid-natación', 'membership',
            channelDescription: 'Membership notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            playSound: true,
            ticker: 'Membresía habilitada');
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      badgeNumber: 1,
      presentSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    await notificationsPlugin.show(9, title, body, notificationDetails);
  }
}
