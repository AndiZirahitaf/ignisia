import 'package:elearning/api/api.dart';
import 'package:elearning/course/course_detail.dart';
import 'package:elearning/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final courseId = int.tryParse(response.payload!);
          if (courseId != null) {
            // Navigasi ke course detail
            Navigator.of(navigatorKey.currentContext!).push(
              MaterialPageRoute(
                builder: (_) => CourseDetailPage(courseId: courseId),
              ),
            );
          }
        }
      },
    );

    // Buat channel tambahan supaya Android bisa munculin notif
    const AndroidNotificationChannel completedChannel =
        AndroidNotificationChannel(
          'course_completed_channel',
          'Course Completed',
          description: 'Notifikasi saat user menyelesaikan course',
          importance: Importance.high,
        );
    await _notif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(completedChannel);
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

  // // Schedule daily reminder at 18:00
  // Future<void> scheduleDailyReminder() async {
  //   final now = tz.TZDateTime.now(tz.local);
  //   var scheduledDate = tz.TZDateTime(
  //     tz.local,
  //     now.year,
  //     now.month,
  //     now.day,
  //     18,
  //   );

  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   }

  //   await _notif.zonedSchedule(
  //     1,
  //     'Ayo lanjut belajar 💡',
  //     'Progress kamu belum selesai hari ini!',
  //     scheduledDate,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'ignisia_channel',
  //         'Ignisia Notifications',
  //         channelDescription: 'Notification channel for Ignisia app',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

  //     matchDateTimeComponents: DateTimeComponents.time,
  //   );
  // }

  Future<List<Map<String, dynamic>>> getOngoingCourses(int userId) async {
    final ownedCourses = await getOwnedCourses(userId); // API call
    List<Map<String, dynamic>> ongoing = [];

    for (var course in ownedCourses) {
      final lessons = await getLessons(course['id'], userId);
      final total = lessons.length;
      final completed = lessons.where((l) => l['completed'] == true).length;

      if (completed < total) {
        ongoing.add({
          "id": course['id'],
          "title": course['title'],
          "remaining": total - completed,
        });
      }
    }

    return ongoing;
  }

  Future<void> scheduleAdvancedDailyReminder(int userId) async {
    final ongoingCourses = await getOngoingCourses(userId);
    if (ongoingCourses.isEmpty) return;

    // Set jam tetap: jam 16:00
    final now = tz.TZDateTime.now(tz.local);
    final fixedTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      16,
      0,
    );
    final List<tz.TZDateTime> scheduledTimes = [fixedTime];

    // Tambah 4 random jam, min interval 2 jam
    final rng = Random();
    while (scheduledTimes.length < 5) {
      int randomHour = rng.nextInt(24);
      int randomMinute = rng.nextInt(60);

      final candidate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        randomHour,
        randomMinute,
      );

      // Cek minimal 2 jam jarak dari jadwal lain
      bool tooClose = scheduledTimes.any(
        (t) => (candidate.difference(t).inMinutes).abs() < 120,
      );
      if (!tooClose) scheduledTimes.add(candidate);
    }

    // Schedule notifications
    int notifId = 1;
    for (var scheduledDate in scheduledTimes) {
      // Pilih satu course random dari ongoingCourses
      final course = ongoingCourses[rng.nextInt(ongoingCourses.length)];

      final title = "Lanjut Belajar 🔔";
      final body =
          "Course '${course['title']}' belum selesai. Yuk lanjut belajar!";

      await _notif.zonedSchedule(
        notifId,
        title,
        body,
        scheduledDate.isBefore(now)
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'learning_channel',
            'Reminder Belajar Ignisia',
            importance: Importance.high,
            priority: Priority.high,
            // ticker: 'ticker',
            // badgeNumber: 1, // Badge untuk notif belum dibaca
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: course['id'].toString(), // Payload: courseId
        matchDateTimeComponents:
            DateTimeComponents.time, // agar repeat setiap hari sama jam
      );

      notifId++;
    }
  }

  Future<void> showCourseCompletedNotification(
    String courseTitle,
    int courseId,
  ) async {
    await _notif.show(
      1000 + courseId, // id unik per course
      "Selamat! 🎉",
      "Kamu sudah menyelesaikan semua lesson di '$courseTitle'",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'course_completed_channel',
          'Course Completed',
          importance: Importance.high,
          priority: Priority.high,
          // badgeNumber: 1, // badge untuk notif belum dibaca
        ),
      ),
      payload: courseId
          .toString(), // Bisa langsung pakai untuk deep link ke course
    );
  }

  // 🔹 Notifikasi simpel jam 00:10
  Future<void> scheduleMidnightNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7,
      15, // jam 00:10
    );

    // Kalau sudah lewat, schedule besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notif.zonedSchedule(
      9999, // id unik untuk notif ini
      "Notifikasi Simpel",
      "Ini notifikasi jam 00:10!",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'simple_channel',
          'Notifikasi Simpel',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time, // repeat tiap hari
    );
  }
}
