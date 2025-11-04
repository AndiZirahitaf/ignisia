// import 'package:elearning/data.dart';
import 'package:elearning/course_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api.dart';

class MyCourses extends StatefulWidget {
  const MyCourses({super.key});

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  int userId = 0;
  bool isLoading = true;
  List<dynamic> ownedCourses = [];

  @override
  void initState() {
    super.initState();
    loadUserDataAndCourses();
  }

  // Gabungkan loading userId & courses
  Future<void> loadUserDataAndCourses() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final id = prefs.getInt('user_id') ?? 0;

    setState(() {
      userId = id;
    });

    await handleOwnedCourses(userId);
  }

  Future<void> handleOwnedCourses(int userId) async {
    try {
      final fetchOwnedCourses = await getOwnedCourses(userId);
      List<Map<String, dynamic>> coursesWithProgress = [];

      for (var course in fetchOwnedCourses) {
        final lessons = await getLessons(course['id'], userId);
        final totalLessons = lessons.length;
        final completedLessons = lessons
            .where((l) => l['completed'] == true)
            .length;

        coursesWithProgress.add({
          ...course,
          'totalLessons': totalLessons,
          'completedLessons': completedLessons,
        });
      }

      if (!mounted) return;
      setState(() {
        ownedCourses = coursesWithProgress;
        isLoading = false;
        debugPrint('Owned courses: $ownedCourses');
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load owned courses')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final ownedCourses = courseList.where((c) => c.owned == true).toList();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70),
            Text(
              'My Courses',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                fontFamily: 'Playfair Display',
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: ownedCourses.length,
              itemBuilder: (context, index) {
                final course = ownedCourses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailPage(courseId: course['id']),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    child: ListTile(
                      title: Text(
                        course['title'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Lesson Dipelajari: ${course['completedLessons']}/${course['totalLessons']}",
                      ),
                      trailing: Text(
                        'Lanjutkan',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
