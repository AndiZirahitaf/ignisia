// import 'package:elearning/data.dart';
import 'package:elearning/course/course_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';

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
    Widget _buildStatusChip(int completed, int total) {
      final isCompleted = completed >= total && total > 0;
      final String text = isCompleted ? 'Completed' : 'Ongoing';
      final Color backgroundColor = isCompleted
          ? Colors.green.shade100
          : Colors.orange.shade100;
      final Color foregroundColor = isCompleted
          ? Colors.green.shade800
          : Colors.orange.shade800;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: foregroundColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
      );
    }

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
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ownedCourses.isEmpty
                ? Center(
                    child: Text(
                      'You have not enrolled in any courses yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: ownedCourses.length,
                      itemBuilder: (context, index) {
                        final course = ownedCourses[index];
                        return GestureDetector(
                          onTap: () async {
                            final bool? statusUpdated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailPage(courseId: course['id']),
                              ),
                            );

                            if (statusUpdated == true) {
                              print(
                                "Kembali dari Course Detail, memuat ulang MyCourses...",
                              );
                              setState(
                                () => isLoading = true,
                              ); // Tampilkan loading
                              await handleOwnedCourses(userId);
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 12.0,
                                      left: 4.0,
                                    ),
                                    child: Icon(
                                      Icons.book,
                                      size: 30,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              course['title'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Materi Dipelajari: ${course['completedLessons']}/${course['totalLessons']}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  _buildStatusChip(
                                    course['completedLessons'],
                                    course['totalLessons'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
