import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  static FlutterLocalNotificationsPlugin? _notifications;

  NotificationService._init();

  static FlutterLocalNotificationsPlugin get notifications {
    _notifications ??= FlutterLocalNotificationsPlugin();
    return _notifications!;
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(initSettings);
  }

  Future<void> scheduleWaterChangeReminder({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'water_change_reminder',
      '換水提醒',
      channelDescription: '提醒您該換水了',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await notifications.pendingNotificationRequests();
  }
} 