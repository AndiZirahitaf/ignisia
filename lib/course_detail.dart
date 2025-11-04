import 'package:elearning/checkout_page.dart';
import 'package:elearning/lesson_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'api/api.dart';

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

  @override
  void initState() {
    super.initState();
    loadUserDataAndCourse();
  }

  Future<void> loadUserDataAndCourse() async {
    // 1. Load userId
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id') ?? 0;

    if (!mounted) return;
    setState(() => userId = id);

    // 2. Cek apakah user punya course
    final ownedCourses = await getOwnedCourses(userId);
    final owned = ownedCourses.any((c) => c['id'] == widget.courseId);

    // 3. Load course detail
    final courseFetched = await getCourseDetail(widget.courseId);

    // 4. Load lessons + progress
    final lessonsFetched = await getLessons(widget.courseId, userId);

    if (!mounted) return;
    setState(() {
      userId = id;
      isOwned = owned;
      course = courseFetched ?? {};
      lessons = lessonsFetched ?? [];
      isLoadingCourse = false;

      // Jika baru beli, unlock first lesson
      if (isOwned && lessons.isNotEmpty) {
        lessons[0]['locked'] = false;
      }
    });
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
    return Scaffold(
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
                    gradient: RadialGradient(
                      colors: [
                        const Color.fromARGB(255, 17, 17, 17),
                        const Color.fromARGB(255, 74, 74, 74),
                      ],
                      center: Alignment.bottomRight,
                      radius: 2.0,
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
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(course['description']),
                  const SizedBox(height: 25),
                  // KATEGORI
                  Text(
                    'Kategori',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                          // shape: RoundedRectangleBorder(
                          //   side: BorderSide(color: Colors.black26, width: 1),
                          //   borderRadius: BorderRadius.horizontal(
                          //     left: Radius.circular(0),
                          //     right: Radius.circular(50),
                          //   ),
                          // ),
                          child: ListTile(
                            enabled: isLessonUnlocked,
                            leading: CircleAvatar(
                              backgroundColor: isLessonUnlocked
                                  ? Colors.blueAccent
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => LessonPage(
                                          courseName: course['title'],
                                          lessons: lessons,

                                          lessonIndex: index,
                                          userId: userId,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  }
                                : null,
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
    );
  }
}
