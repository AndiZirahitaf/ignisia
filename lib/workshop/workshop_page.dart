import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';

class WorkshopPage extends StatefulWidget {
  const WorkshopPage({super.key});

  @override
  State<WorkshopPage> createState() => _WorkshopPageState();
}

class _WorkshopPageState extends State<WorkshopPage> {
  final MapController _mapController = MapController();
  LatLng? _userPosition;
  List<dynamic> workshops = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWorkshops();
    _getCurrentLocation();
  }

  Future<void> loadWorkshops() async {
    try {
      final data = await getWorkshops();
      setState(() {
        workshops = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Workshop di Sekitar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(-2.5489, 118.0149),
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
                            markers: workshops
                                .map(
                                  (w) => Marker(
                                    point: LatLng(
                                      w['latitude'],
                                      w['longitude'],
                                    ),
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
                                          builder: (context) =>
                                              _workshopSheet(w),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),

                      // ====== BUTTON CURRENT LOCATION ======
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

                // ================= LIST =================
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workshops.length,
                    itemBuilder: (context, index) {
                      final w = workshops[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              color: Colors.black12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_pin,
                                          size: 15,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          w['address'],
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 15,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          _formatDate(w['date']),
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final Uri uri = Uri.parse(
                                      'https://www.google.com/maps/dir/?api=1&destination=${w['latitude']},${w['longitude']}&travelmode=driving',
                                    );

                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      final fallbackUri = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=${w['latitude']},${w['longitude']}',
                                      );
                                      await launchUrl(
                                        fallbackUri,
                                        mode: LaunchMode.platformDefault,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                  child: const Icon(Icons.directions, size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _workshopSheet(w) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            w['title'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 6),
              Text(w['address']),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.date_range, color: Colors.grey),
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
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                final fallbackUri = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=${w['latitude']},${w['longitude']}',
                );
                await launchUrl(fallbackUri, mode: LaunchMode.platformDefault);
              }
            },
            icon: const Icon(Icons.directions),
            label: const Text('Arahkan ke Lokasi'),
          ),
        ],
      ),
    );
  }
}
