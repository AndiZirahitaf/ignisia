// api.dart
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:firebase_messaging/firebase_messaging.dart';

String ApiUrl = 'http://10.0.2.2:3000/api/';

// ==================== COURSES ====================
String GET_COURSES = '${ApiUrl}courses';
String GET_COURSE_DETAIL(int id) => '${ApiUrl}courses/$id';
String PURCHASE_COURSE(int id) => '${ApiUrl}courses/$id/purchase';
String GET_COURSES_OWNED(int userId) => '${ApiUrl}courses/owned/$userId';

// GET all courses
Future<List<dynamic>> getCourses() async {
  final response = await http.get(Uri.parse(GET_COURSES));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load courses');
  }
}

// GET course detail
Future<Map<String, dynamic>> getCourseDetail(int id) async {
  final response = await http.get(Uri.parse(GET_COURSE_DETAIL(id)));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load course detail');
  }
}

// POST purchase course
Future<bool> purchaseCourse(int courseId, int userId) async {
  final response = await http.post(
    Uri.parse(PURCHASE_COURSE(courseId)),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"user_id": userId}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

// GET courses owned by user
Future<List<dynamic>> getOwnedCourses(int userId) async {
  final response = await http.get(Uri.parse(GET_COURSES_OWNED(userId)));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load owned courses');
  }
}

// ==================== LESSONS ====================
String GET_A_LESSON(int lessonId) => '${ApiUrl}lessons/$lessonId';
String GET_LESSONS(int courseId, int userId) =>
    '${ApiUrl}lessons/course/$courseId/user/$userId';
String COMPLETE_LESSON(int lessonId) => '${ApiUrl}lessons/$lessonId/complete';

// GET a lesson
Future<Map<String, dynamic>?> getALesson(int lessonID) async {
  final response = await http.get(Uri.parse(GET_A_LESSON(lessonID)));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load lesson detail');
  }
}

// GET lessons by course and user (locked/unlocked)
Future<List<dynamic>> getLessons(int courseId, int userId) async {
  final response = await http.get(Uri.parse(GET_LESSONS(courseId, userId)));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load lessons');
  }
}

// POST mark lesson completed (now includes courseId)

Future<List<int>> completeLesson(int lessonId, int userId) async {
  final response = await http.post(
    Uri.parse(COMPLETE_LESSON(lessonId)),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"user_id": userId}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<int>.from(data["completedLessons"]); // hasilnya list lesson_id
  } else {
    throw Exception("Gagal update progress: ${response.body}");
  }
}

// ==================== USERS ====================
String REGISTER_USER = '${ApiUrl}users/register';
String LOGIN_USER = '${ApiUrl}users/login';
String GET_USER(int id) => '${ApiUrl}users/$id';
String UPDATE_USER(int id) => '${ApiUrl}users/$id';

// POST register
Future<Map<String, dynamic>> registerUser(
  String name,
  String email,
  String password, {
  String? photoUrl,
}) async {
  final response = await http.post(
    Uri.parse(REGISTER_USER),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "photo_url": photoUrl ?? "",
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to register user');
  }
}

// POST login
Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse(LOGIN_USER),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email, "password": password}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Login failed');
  }
}

// GET user profile
Future<Map<String, dynamic>> getUser(int userId) async {
  final response = await http.get(Uri.parse(GET_USER(userId)));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to get user profile');
  }
}

Future<Map<String, dynamic>> updateUser(
  int id, {
  String? name,
  String? email,
  String? password,
  String? photoUrl,
}) async {
  final response = await http.put(
    Uri.parse(UPDATE_USER(id)),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "photo_url": photoUrl,
    }),
  );

  print("STATUS UPDATE: ${response.statusCode}");
  print("BODY UPDATE: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to update user');
  }
}

// ==================== WORKSHOPS ====================
String GET_WORKSHOPS = '${ApiUrl}workshops';
String GET_WORKSHOP_DETAIL(int id) => '${ApiUrl}workshops/$id';

Future<List<dynamic>> getWorkshops() async {
  final response = await http.get(Uri.parse(GET_WORKSHOPS));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load workshops');
  }
}

Future<Map<String, dynamic>> getWorkshopDetail(int id) async {
  final response = await http.get(Uri.parse(GET_WORKSHOP_DETAIL(id)));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load workshop detail');
  }
}

// ==================== SEMINARS ====================
String GET_SEMINARS = '${ApiUrl}seminars';
String GET_SEMINAR_DETAIL(int id) => '${ApiUrl}seminars/$id';

Future<List<dynamic>> getSeminars() async {
  final response = await http.get(Uri.parse(GET_SEMINARS));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load seminars');
  }
}

Future<Map<String, dynamic>> getSeminarDetail(int id) async {
  final response = await http.get(Uri.parse(GET_SEMINAR_DETAIL(id)));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load seminar detail');
  }
}

// ==================== CATEGORIES ====================
String GET_CATEGORIES = '${ApiUrl}categories';

Future<List<dynamic>> getCategories() async {
  final response = await http.get(Uri.parse(GET_CATEGORIES));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load categories');
  }
}

// // ==================== FIREBASE MESSAGING (Flutter side) ====================

// // Ambil device token FCM
// Future<String?> getDeviceToken() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   if (settings.authorizationStatus == AuthorizationStatus.denied) {
//     print("User menolak push notification");
//     return null;
//   }

//   String? token = await messaging.getToken();
//   print("Device Token: $token");
//   return token;
// }

// // Kirim device token ke backend
// Future<void> registerDeviceToken(int userId, String token) async {
//   await http.post(
//     Uri.parse("http://YOUR_SERVER_ADDRESS/register-token"),
//     body: {"user_id": userId.toString(), "token": token},
//   );
// }

// // Listener untuk menerima notif saat app foreground
// void setupFCMListener() {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("Terima notifikasi (onMessage): ${message.notification?.title}");
//     print("Body: ${message.notification?.body}");
//     // Tampilkan SnackBar, dialog, atau update UI via state management
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print("User buka app dari notif: ${message.notification?.title}");
//   });
// }
