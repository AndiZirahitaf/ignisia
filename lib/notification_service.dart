import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // 1. Singleton instance
  static final NotificationService instance = NotificationService._internal();

  // 2. Private constructor
  NotificationService._internal();

  // 3. Factory constructor
  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 2. Initialize timezone
    tz.initializeTimeZones();

    // 3. Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notif.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
            // Optional: handle tap
          },
    );
  }

  // Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'ignisia_channel', // channel id
          'Ignisia Notifications', // channel name
          channelDescription: 'Notification channel for Ignisia app',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notif.show(id, title, body, details, payload: payload);
  }

  // Schedule daily reminder at 18:00
  Future<void> scheduleDailyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notif.zonedSchedule(
      1,
      'Ayo lanjut belajar 💡',
      'Progress kamu belum selesai hari ini!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ignisia_channel',
          'Ignisia Notifications',
          channelDescription: 'Notification channel for Ignisia app',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
