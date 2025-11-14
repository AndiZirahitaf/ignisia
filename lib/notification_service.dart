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
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    tz.initializeTimeZones();

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

  // Future<void> showNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   String? payload,
  // }) async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //         'ignisia_channel', // channel id
  //         'Ignisia Notifications', // channel name
  //         channelDescription: 'Notification channel for Ignisia app',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         showWhen: false,
  //       );

  //   const NotificationDetails details = NotificationDetails(
  //     android: androidDetails,
  //   );

  //   await _notif.show(id, title, body, details, payload: payload);
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

      bool tooClose = scheduledTimes.any(
        (t) => (candidate.difference(t).inMinutes).abs() < 120,
      );
      if (!tooClose) scheduledTimes.add(candidate);
    }

    int notifId = 1;
    for (var scheduledDate in scheduledTimes) {
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
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: course['id'].toString(),
        matchDateTimeComponents: DateTimeComponents.time,
      );

      notifId++;
    }
  }

  Future<void> showCourseCompletedNotification(
    String courseTitle,
    int courseId,
  ) async {
    await _notif.show(
      1000 + courseId,
      "Selamat! 🎉",
      "Kamu sudah menyelesaikan semua lesson di '$courseTitle'",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'course_completed_channel',
          'Course Completed',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: courseId.toString(),
    );
  }
}
