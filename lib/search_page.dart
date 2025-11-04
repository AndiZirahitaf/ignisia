import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api.dart';
import 'course_detail.dart';

class SearchPage extends StatefulWidget {
  final bool autoFocus;
  const SearchPage({super.key, required this.autoFocus});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> allCourses = [];
  List<dynamic> filteredCourses = [];
  List<dynamic> allCategories = [];
  List<dynamic> selectedCategories = [];
  String searchQuery = '';
  bool isLoading = true;
  int userId = 0;
  List<int> ownedCourseIds = [];

  @override
  void initState() {
    super.initState();
    loadUserAndCourses();
    fetchCategories();
    if (widget.autoFocus) {
      // kasih sedikit delay biar build() selesai dulu
      Future.delayed(Duration(milliseconds: 300), () {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final categories = await getCategories();
    if (!mounted) return;
    setState(() {
      allCategories = categories;
    });
  }

  Future<void> loadUserAndCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id') ?? 0;

    // Load courses owned
    final ownedCourses = await getOwnedCourses(id);
    final ownedIds = ownedCourses.map<int>((c) => c['id'] as int).toList();

    // Load all courses
    final courses = await getCourses();

    // Load semua kategori dari API
    final categories = await getCategories();

    // Ambil semua kategori unik yang muncul di course
    final courseCategories = <String>{};
    for (var course in courses) {
      if (course['categories'] is List) {
        courseCategories.addAll(List<String>.from(course['categories']));
      }
    }

    // Gabungkan semua kategori dari API dan dari course
    final mergedCategories = {
      ...categories.map((c) => c['name'].toString()),
      ...courseCategories,
    }.toList();

    if (!mounted) return;
    setState(() {
      userId = id;
      ownedCourseIds = ownedIds;
      allCourses = courses;
      filteredCourses = courses;
      allCategories = mergedCategories;
      isLoading = false;
    });
  }

  void applyFilters() {
    List<dynamic> temp = allCourses;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      temp = temp
          .where(
            (c) => c['title'].toString().toLowerCase().contains(
              searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    // Filter by selected categories
    if (selectedCategories.isNotEmpty) {
      temp = temp.where((c) {
        final cats = c['categories'] is List
            ? List<String>.from(c['categories'])
            : [];
        return selectedCategories.any((cat) => cats.contains(cat));
      }).toList();
    }

    setState(() {
      filteredCourses = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Search Courses')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Courses',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 🔹 Search bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: widget.autoFocus,
                decoration: _inputDecoration('Cari Kursus...').copyWith(
                  // Tambahkan ikon "clear" di kanan
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(CupertinoIcons.clear_circled_solid),
                          onPressed: () {
                            _searchController.clear();
                            searchQuery = '';
                            applyFilters();
                            setState(() {}); // refresh biar ikon hilang
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  searchQuery = value;
                  applyFilters();
                  setState(() {}); // biar suffixIcon muncul/hilang dinamis
                },
              ),
            ),

            // 🔹 Category filter (multi-select)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final category = allCategories[index];
                  final isSelected = selectedCategories.contains(category);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCategories.add(category);
                          } else {
                            selectedCategories.remove(category);
                          }
                          applyFilters();
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // 🔹 GridView hasil search
            SizedBox(height: 10),
            Expanded(
              child: filteredCourses.isEmpty
                  ? const Center(child: Text('No courses found'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 5,
                            // childAspectRatio: 0.7,
                          ),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        final isOwned = ownedCourseIds.contains(course['id']);
                        final lessons = course['lessons'] is List
                            ? List.from(course['lessons'])
                            : <dynamic>[];
                        final completed = lessons
                            .where((l) => l['completed'] == true)
                            .length;
                        final progress = lessons.isEmpty
                            ? 0.0
                            : completed / lessons.length;
                        final priceText = course['price'] == 0
                            ? 'Gratis'
                            : 'Rp ${course['price'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailPage(courseId: course['id']),
                              ),
                            );
                          },
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: [
                                    RadialGradient(
                                      colors: [
                                        const Color.fromARGB(255, 2, 34, 71),
                                        const Color.fromARGB(255, 11, 81, 161),
                                      ],
                                      center: Alignment.bottomRight,
                                      radius: 1.0,
                                    ),

                                    RadialGradient(
                                      colors: [
                                        const Color.fromARGB(255, 41, 2, 71),
                                        const Color.fromARGB(255, 73, 11, 161),
                                      ],
                                      center: Alignment.bottomRight,
                                      radius: 1.0,
                                    ),
                                    RadialGradient(
                                      colors: [
                                        const Color.fromARGB(255, 71, 47, 2),
                                        const Color.fromARGB(255, 161, 96, 11),
                                      ],
                                      center: Alignment.bottomRight,
                                      radius: 1.0,
                                    ),
                                    RadialGradient(
                                      colors: [
                                        const Color.fromARGB(255, 98, 36, 28),
                                        const Color.fromARGB(255, 172, 74, 61),
                                      ],
                                      center: Alignment.bottomRight,
                                      radius: 1.0,
                                    ),
                                    RadialGradient(
                                      colors: [
                                        const Color.fromARGB(255, 9, 102, 45),
                                        const Color.fromARGB(255, 10, 143, 70),
                                      ],
                                      center: Alignment.bottomRight,
                                      radius: 1.0,
                                    ),
                                  ][index % 5],
                                ),

                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 20,
                                      right: -20,
                                      child: Opacity(
                                        opacity: 0.5,
                                        child: Image.asset(
                                          color: Colors.black38,
                                          'lib/assets/course_${index + 1}.png',
                                          width: 130,
                                          height: 130,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: 155,
                                            child: Text(
                                              course['title'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2.0,
                                              horizontal: 6.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              priceText,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 20, // 🔹 padding kiri-kanan biar kursor gak nempel
      ),
    );
  }
}
