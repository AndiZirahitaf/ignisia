import 'package:elearning/app_theme.dart';
import 'package:elearning/certificate_page.dart';
import 'package:elearning/course/checkout_page.dart';
import 'package:elearning/course/lesson_page.dart';
import 'package:elearning/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../api/api.dart';

// import 'data.dart';

class CourseDetailPage extends StatefulWidget {
  final int courseId;

  const CourseDetailPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => CourseDetailPageState();
}

class CourseDetailPageState extends State<CourseDetailPage> {
  bool isLoadingCourse = true;
  Map<String, dynamic> course = {};
  List<dynamic> lessons = [];
  bool isOwned = false;
  int userId = 0;

  final Map<String, Gradient> courseGradients = {
    "course_1": RadialGradient(
      colors: [
        Color.fromARGB(255, 2, 34, 71),
        Color.fromARGB(255, 11, 81, 161),
      ],
      center: Alignment.bottomRight,
      radius: 1.0,
    ),
    "course_2": RadialGradient(
      colors: [
        Color.fromARGB(255, 41, 2, 71),
        Color.fromARGB(255, 73, 11, 161),
      ],
      center: Alignment.bottomRight,
      radius: 1.0,
    ),
    "course_3": RadialGradient(
      colors: [
        Color.fromARGB(255, 71, 47, 2),
        Color.fromARGB(255, 161, 96, 11),
      ],
      center: Alignment.bottomRight,
      radius: 1.0,
    ),
    "course_4": RadialGradient(
      colors: [
        Color.fromARGB(255, 98, 36, 28),
        Color.fromARGB(255, 172, 74, 61),
      ],
      center: Alignment.bottomRight,
      radius: 1.0,
    ),
    "course_5": RadialGradient(
      colors: [
        Color.fromARGB(255, 9, 102, 45),
        Color.fromARGB(255, 10, 143, 70),
      ],
      center: Alignment.bottomRight,
      radius: 1.0,
    ),
  };

  @override
  void initState() {
    super.initState();
    loadUserDataAndCourse();
  }

  // Fungsi yang sudah ada (tidak perlu diubah)
  Future<void> loadUserDataAndCourse() async {
    // ... (Logika pemuatan data tetap sama)
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id') ?? 0;

    if (!mounted) return;
    setState(() => userId = id);

    final ownedCourses = await getOwnedCourses(userId);
    final owned = ownedCourses.any((c) => c['id'] == widget.courseId);

    final courseFetched = await getCourseDetail(widget.courseId);

    // **Ini bagian penting: Memuat data pelajaran terbaru dari API**
    final lessonsFetched = await getLessons(widget.courseId, userId);

    if (!mounted) return;
    setState(() {
      userId = id;
      isOwned = owned;
      course = courseFetched;
      lessons = lessonsFetched;
      isLoadingCourse = false;

      // ... (Logika unlock lesson pertama tetap sama)
      if (isOwned && lessons.isNotEmpty) {
        lessons[0]['locked'] = false;
      }
    });
  }

  void _checkAndNotifyCourseCompleted() async {
    final totalLessons = lessons.length;
    final completedLessons = lessons
        .where((l) => l['completed'] == true)
        .length;

    if (completedLessons == totalLessons && totalLessons > 0) {
      await NotificationService.instance.showCourseCompletedNotification(
        course['title'],
        course['id'],
      );
    }
  }

  // Fungsi Navigasi yang Dimodifikasi
  void _navigateToLesson(lesson, int index) async {
    // 1. Panggil push dan TUNGGU hasilnya (sampai LessonPage di-pop)
    final bool? lessonUpdated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonPage(
          courseName: course['title'],
          lessons: lessons,
          lessonIndex: index,
          userId: userId,
          courseId: widget.courseId, // Tambahkan courseId untuk keamanan
        ),
      ),
    );

    // 2. Jika LessonPage mengembalikan nilai 'true', panggil ulang
    //    loadUserDataAndCourse() untuk me-refresh list lesson.
    if (lessonUpdated == true) {
      print("Lesson Page Selesai, Memuat ulang status lesson...");
      setState(() => isLoadingCourse = true); // Tampilkan loading sebentar
      await loadUserDataAndCourse();
      _checkAndNotifyCourseCompleted();
    }
  }

  void handlePurchase() async {
    bool success = await purchaseCourse(widget.courseId, userId);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Purchase successful!")));

      if (!mounted) return;
      setState(() {
        isOwned = true;
        if (lessons.isNotEmpty)
          lessons[0]['locked'] = false; // unlock first lesson
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Purchase failed!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLessons = lessons.length;
    final completedLessons = lessons
        .where((l) => l['completed'] == true)
        .length;

    if (isLoadingCourse) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (course.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Course tidak ditemukan")),
      );
    }
    final theme = Theme.of(context);
    return WillPopScope(
      // 👈 BUNGKUS DENGAN WILLPOPSCOPE
      onWillPop: () async {
        // Ketika tombol back (pop) ditekan, kembalikan 'true'.
        // Ini akan diterima oleh MyCourses yang memanggil push.
        Navigator.of(context).pop(true);
        // Mengembalikan 'false' untuk mencegah Navigator pop lagi secara otomatis.

        return false;
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Color.fromARGB(255, 17, 17, 17),
              pinned: true,
              expandedHeight: 200,
              // title: Text("Asdasd"),
              // actions: [
              //   IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              //   IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              // ],
              flexibleSpace: FlexibleSpaceBar(
                // centerTitle: true,
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 15,
                ),
                title: Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    course['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                background: Hero(
                  tag: 'course-hero-${course['id']}',
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:
                          courseGradients[course['logo_url']] ??
                          courseGradients
                              .values
                              .first, // fallback kalau tidak ada
                    ),
                    // Align the image first, then apply a translation on x/y axis.
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Transform.translate(
                        offset: const Offset(
                          -20,
                          10,
                        ), // x, y in logical pixels (adjust as needed)
                        child: Opacity(
                          opacity: 0.8,
                          child: Image.asset(
                            color: Colors.black38,
                            'lib/assets/${course['logo_url']}.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    // JUMLAH LESSON & HARGA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.book, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${lessons.length} Materi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 15),
                            isOwned
                                ? Icon(
                                    completedLessons >= totalLessons &&
                                            totalLessons > 0
                                        ? Icons.done
                                        : Icons.hourglass_bottom,
                                    color: Colors.grey[600],
                                    size: 20,
                                  )
                                : Container(),
                            SizedBox(width: 4),
                            isOwned
                                ? Text(
                                    completedLessons >= totalLessons &&
                                            totalLessons > 0
                                        ? 'Completed'
                                        : 'Ongoing',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),

                        // const SizedBox(width: 16),
                        isOwned
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Dimiliki',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.price_change,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),

                                  Text(
                                    course['price'] == 0
                                        ? 'Free'
                                        : 'Rp ${course['price']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // DESKRIPSI
                    Text(
                      'Mengenai Kursus Ini',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(course['description']),
                    const SizedBox(height: 25),
                    // KATEGORI
                    Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: (() {
                          final cats = course['categories'] is List
                              ? List.from(course['categories'])
                              : <dynamic>[];
                          if (cats.isEmpty) {
                            return [
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Chip(label: Text('Uncategorized')),
                              ),
                            ];
                          }
                          return cats
                              .map(
                                (t) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(t.toString()),
                                    backgroundColor: Colors.grey[200],
                                    shape: StadiumBorder(
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList();
                        })(),
                      ),
                    ),
                    isOwned
                        ? Text("")
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutPage(
                                      course: course,
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Beli Kursus Ini'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                    Divider(color: Colors.grey[300]),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Materi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        isOwned
                            ? Text(
                                'Materi Dipelajari: $completedLessons / $totalLessons',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ListView.builder(
                      padding: EdgeInsets.only(bottom: 20),
                      shrinkWrap: true,
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        final isLessonUnlocked =
                            isOwned && !(lesson['locked'] ?? true);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 6.0,
                          ),
                          child: Material(
                            color: const Color.fromARGB(31, 153, 153, 153),

                            // color: AppColors.secondary,
                            child: ListTile(
                              title: Text(
                                lesson['title'],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: lesson['subtitle'] != null
                                  ? Text(
                                      maxLines: 2,
                                      lesson['subtitle'],
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: Icon(
                                isLessonUnlocked
                                    ? Icons.arrow_forward_ios
                                    : Icons.lock,
                                size: 16,
                              ),
                              onTap: isLessonUnlocked
                                  ? () async {
                                      // *** GANTI DENGAN FUNGSI BARU ***
                                      _navigateToLesson(lesson, index);
                                    }
                                  : null,
                              enabled: isLessonUnlocked,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isLessonUnlocked
                                        ? const Color.fromARGB(255, 59, 97, 221)
                                        : Colors.grey.shade400,
                                    width: 5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: isLessonUnlocked
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade400,
                                  child: Text(
                                    '${index + 1}',
                                    style: isLessonUnlocked
                                        ? TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          )
                                        : TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.bold,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
