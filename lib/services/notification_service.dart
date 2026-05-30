import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../models/reminder.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'reminders';
  static const String _channelName = 'Reminders';

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings: initSettings);

    // Android 13+ runtime notification permission.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  NotificationDetails _details() {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'VoiceNote reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: androidDetails, iOS: darwinDetails);
  }

  Future<void> scheduleReminder(Reminder reminder, String noteTitle) async {
    final notificationId = reminder.id.hashCode.abs() % (1 << 30);
    final truncated =
        noteTitle.length > 40 ? '${noteTitle.substring(0, 37)}...' : noteTitle;
    final title = 'VoiceNote: $truncated';
    final body = reminder.text;
    final details = _details();

    final when = reminder.dateTime;
    final now = DateTime.now();

    if (when == null || !when.isAfter(now)) {
      await _plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
      );
      return;
    }

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
