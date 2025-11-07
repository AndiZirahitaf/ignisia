// import 'package:elearning/data.dart';

import 'package:elearning/app_theme.dart';
import 'package:elearning/course/course_detail.dart';

import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import '../api/api.dart';

class LessonPage extends StatefulWidget {
  final List<dynamic> lessons;

  final int lessonIndex;

  final String courseName;

  final int userId;

  final int courseId;

  // final Course course;

  const LessonPage({
    Key? key,

    required this.lessons,

    required this.lessonIndex,

    required this.courseName,

    required this.userId,
    required this.courseId,
  }) : super(key: key);

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late ScrollController _scrollController = ScrollController();

  bool isAtBottom = false;

  bool isLoading = true;

  Map<String, dynamic> lesson = {};

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(_scrollListener);

    _fetchLesson();
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // 🔹 User sudah scroll sampai bawah

        setState(() {
          isAtBottom = true;
        });

        print("User reached bottom!");
      } else {
        // 🔹 User ada di atas

        setState(() {
          isAtBottom = false;
        });
      }
    }
  }

  Future<void> _fetchLesson() async {
    final Map<String, dynamic>? lessonFetched = await getALesson(
      widget.lessons[widget.lessonIndex]['id'],
    );

    if (lessonFetched == null) {
      setState(() {
        isLoading = false;

        lesson = {};
      });

      return;
    }

    setState(() {
      lesson = lessonFetched;

      isLoading = false;
    });

    _markLessonCompleted(widget.lessonIndex);
  }

  void _markLessonCompleted(int index) async {
    print(
      "Marking lesson ${widget.lessons[index]['id']} as completed. User: ${widget.userId}",
    );
    final lessonId = widget.lessons[index]['id'];

    // 1. Tandai selesai di backend
    await completeLesson(lessonId, widget.userId);

    // 2. Reload daftar lesson dari backend (supaya lock/unlock akurat)
    final updatedLessons = await getLessons(widget.courseId, widget.userId);

    // 3. Update UI
    if (mounted) {
      setState(() {
        widget.lessons.clear();
        widget.lessons.addAll(updatedLessons);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasPrev = widget.lessonIndex > 0;

    final hasNext =
        widget.lessonIndex >= 0 &&
        widget.lessonIndex < widget.lessons.length - 1;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: -5.0,
        foregroundColor: Colors.white,
        title: Text(
          widget.courseName,
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w900,
          ),
        ),

        leading: IconButton(
          // padding: const EdgeInsets.only(left: 12) ,
          icon: const Icon(Icons.arrow_back_ios),

          onPressed: () => Navigator.of(context).pop(true),
        ),

        backgroundColor: AppColors.dark,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: MarkdownBody(
            data: lesson['content'] ?? '',

            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(
                  p: const TextStyle(fontSize: 16, height: 1.5),

                  h1: const TextStyle(
                    fontSize: 24,

                    fontWeight: FontWeight.bold,
                  ),

                  h2: const TextStyle(
                    fontSize: 20,

                    fontWeight: FontWeight.bold,
                  ),

                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.blue,
                  ),

                  code: const TextStyle(
                    backgroundColor: Color(0xfff5f5f5),

                    fontFamily: 'monospace',
                  ),
                ),
          ),
        ),
      ),

      // 🔹 Fixed bottom bar (tidak ikut scroll)
      bottomNavigationBar: SafeArea(
        top: false,

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),

          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,

            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),

                blurRadius: 8,

                offset: const Offset(0, -2),
              ),
            ],
          ),

          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              // circular icon-only Prev button
              Container(
                width: 44,

                height: 44,

                child: IconButton(
                  padding: EdgeInsets.zero,

                  icon: const Icon(Icons.arrow_back_ios_new),

                  color: hasPrev ? Colors.black87 : Colors.black12,

                  onPressed: hasPrev
                      ? () {
                          // final target = widget.lessons[widget.lessonIndex - 1];

                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder: (context) => LessonPage(
                                lessonIndex: widget.lessonIndex - 1,

                                lessons: widget.lessons,

                                courseName: widget.courseName,

                                userId: widget.userId,
                                courseId: widget.courseId,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),

              SizedBox(width: 12),

              Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Text(
                    lesson['title'] ?? '',

                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  Text(
                    '${widget.lessonIndex + 1} / ${widget.lessons.length}',

                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              SizedBox(width: 12),

              Container(
                width: 44,

                height: 44,

                child: IconButton(
                  padding: EdgeInsets.zero,

                  icon: const Icon(Icons.arrow_forward_ios),

                  color: hasNext ? Colors.black87 : Colors.black12,

                  onPressed: hasNext
                      ? () {
                          // final target = widget.lessons[widget.lessonIndex + 1];

                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder: (context) => LessonPage(
                                lessonIndex: widget.lessonIndex + 1,

                                lessons: widget.lessons,

                                courseName: widget.courseName,

                                userId: widget.userId,
                                courseId: widget.courseId,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
