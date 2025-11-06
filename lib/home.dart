import 'package:elearning/app_theme.dart';
import 'package:elearning/course/course_detail.dart';
import 'package:elearning/course/search_page.dart';
import 'package:elearning/seminar/seminar_detail.dart';
import 'package:elearning/workshop/workshop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final MapController _mapController = MapController();
  LatLng? _userPosition;
  String name = '';
  bool isLoading = true;
  List<dynamic> orderData = [];
  bool isLoadingOrders = true;
  bool isLoadingCourses = true;
  bool isLoadingWorkshops = true;
  bool isLoadingSeminars = true;
  List<dynamic> courses = [];
  List<dynamic> seminars = [];
  List<dynamic> workshops = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    _loadCourses();
    _loadSeminars();
    loadWorkshops();
    _getCurrentLocation();
  }

  Future<void> loadWorkshops() async {
    try {
      final data = await getWorkshops();
      setState(() {
        workshops = data;
        isLoadingWorkshops = false;
      });
    } catch (e) {
      setState(() => isLoadingWorkshops = false);
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('user_name') ?? 'John Doe';
    final firstName = fullName.trim().isEmpty
        ? 'John'
        : fullName.trim().split(RegExp(r'\s+'))[0];
    setState(() {
      name = firstName;
    });
  }

  Future<void> _loadCourses() async {
    final List<dynamic> fetched = await getCourses();
    setState(() {
      courses = fetched;
      isLoadingCourses = false;
    });
    // Cetak daftar course ke console
    for (var c in courses) {
      debugPrint(
        'Course: id=${c['id']}, title=${c['title']}, price=${c['price']}',
      );
    }
  }

  Future<void> _loadSeminars() async {
    final List<dynamic> fetched = await getSeminars();
    setState(() {
      seminars = fetched;
      isLoadingSeminars = false;
    });
    for (var c in seminars) {
      debugPrint(
        'Seminars: id=${c['id']}, title=${c['title']}, datetime=${c['datetime']}',
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan lokasi belum diaktifkan')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi ditolak permanen')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
    });
  }

  String _formatDate(dynamic datetime) {
    final dateTime = DateTime.parse(datetime);
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(dateTime);
  }

  String _formatTime(dynamic datetime) {
    final dateTime = DateTime.parse(datetime);
    final formatter = DateFormat('HH:mm', 'id_ID');
    final end = "${formatter.format(dateTime)} WIB";
    return end;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Ignisia',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 254, 252),
        foregroundColor: Colors.black,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20.0),
        //     child: GestureDetector(
        //       onTap: () {
        //         // TODO: handle avatar tap (navigate to profile, open menu, etc.)
        //       },
        //       child: CircleAvatar(
        //         radius: 25,
        //         // Use backgroundImage: NetworkImage('...') to show a photo instead of an initial
        //         backgroundImage: Image.asset('assets/images/profile.png').image,
        //         backgroundColor: const Color(0xFFFFBFB6),
        //         // child: Image.asset('assets/images/profile.png'),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                alignment: Alignment.topRight,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/star_light.png',
                    width: 120,
                    alignment: Alignment.topRight,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, $name!",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Outfit',
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          'Belajar apa hari ini?',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Outfit',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Color.fromARGB(255, 208, 208, 208),
                  width: 2,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey[600]),
                  hintText: 'Cari mata pelajaran...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchPage(autoFocus: true),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Kursus Untuk Anda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // fontFamily: 'Trocchi',
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: isLoadingCourses
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(right: 12),
                      itemBuilder: (context, index) {
                        final course = courses[index];
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

            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Workshop di Sekitar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'Trocchi',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WorkshopPage()),
                    );
                  },
                  child: Text("More"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          -2.5489,
                          118.0149,
                        ), // Tengah Indonesia
                        initialZoom: 1.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.ignisia.app',
                        ),
                        if (_userPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _userPosition!,
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            // Lokasi user (jika tersedia)

                            // Marker workshop dari data.dart
                            ...workshops.map(
                              (w) => Marker(
                                point: LatLng(w['latitude'], w['longitude']),
                                width: 80,
                                height: 80,
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              w['title'],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(w['address']),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.date_range,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(w['date']),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                final Uri uri = Uri.parse(
                                                  'https://www.google.com/maps/dir/?api=1&destination=${w['latitude']},${w['longitude']}&travelmode=driving',
                                                );

                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(
                                                    uri,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Tidak bisa membuka Maps',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.directions,
                                              ),
                                              label: const Text(
                                                'Arahkan ke Lokasi',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        elevation: 4,
                        onPressed: () {
                          if (_userPosition != null) {
                            _mapController.move(
                              _userPosition!,
                              4,
                            ); // Zoom ke dekat user
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Lokasi tidak ditemukan"),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Info Webinar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // fontFamily: 'Trocchi',
              ),
            ),

            SizedBox(height: 10),

            isLoadingSeminars
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: seminars.length,
                    itemBuilder: (context, index) {
                      final seminar = seminars[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: const Color.fromARGB(255, 255, 249, 241),
                          // shape: RoundedRectangleBorder(
                          //   // borderRadius: BorderRadius.circular(15),
                          //   side: BorderSide(
                          //     color: Colors.grey.shade300,
                          //     width: 1,
                          //   ),
                          // ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SeminarDetailPage(
                                    seminarId: seminar['id'],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          seminar['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          spacing: 50,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  220,
                                                  210,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatDate(
                                                      seminar['datetime'],
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: Colors.black54,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  // Gunakan fungsi untuk memformat HANYA tanggal
                                                  _formatTime(
                                                    seminar['datetime'],
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 3. Icon Chevron (Trailing)
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
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
    );
  }
}
