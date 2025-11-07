import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/api.dart';

class SeminarDetailPage extends StatefulWidget {
  final int seminarId;

  const SeminarDetailPage({Key? key, required this.seminarId})
    : super(key: key);

  @override
  State<SeminarDetailPage> createState() => _SeminarDetailPageState();
}

class _SeminarDetailPageState extends State<SeminarDetailPage> {
  Map<String, dynamic> seminar = {};
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _expandedDescription = false;
  String selectedZone = 'WIB';

  @override
  void initState() {
    super.initState();
    _loadSeminarDetails();
  }

  Future<void> _loadSeminarDetails() async {
    final seminarDetails = await getSeminarDetail(widget.seminarId);
    setState(() {
      seminar = seminarDetails;
      _isLoading = false;
    });
  }

  DateTime _convertToTimeZone(DateTime dateTime, String zone) {
    switch (zone) {
      case 'WITA':
        return dateTime.add(const Duration(hours: 1));
      case 'WIT':
        return dateTime.add(const Duration(hours: 2));
      case 'London':
        return dateTime.subtract(const Duration(hours: 7));
      default:
        return dateTime;
    }
  }

  String _formatDate(dynamic datetime, String zone) {
    final dateTime = DateTime.parse(datetime);
    final localized = _convertToTimeZone(dateTime, zone);
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(localized);
  }

  String _formatTime(dynamic datetime, String zone) {
    final dateTime = DateTime.parse(datetime);
    final localized = _convertToTimeZone(dateTime, zone);
    final formatter = DateFormat('HH:mm', 'id_ID');
    return "${formatter.format(localized)} $zone";
  }

  // void _toggleFavorite() {
  //   setState(() => _isFavorite = !_isFavorite);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         _isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
  //       ),
  //       duration: const Duration(milliseconds: 800),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil mendaftar ke "${seminar['title']}"'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dateTime = DateTime.parse(seminar['datetime']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Detail Webinar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       _isFavorite ? Icons.favorite : Icons.favorite_border,
        //       color: _isFavorite ? Colors.red : Colors.black54,
        //     ),
        //     onPressed: _toggleFavorite,
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                seminar['title'],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Trocchi',
                ),
              ),
              const SizedBox(height: 45),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // increased radius
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tanggal: ",
                          style: const TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(seminar['datetime'], selectedZone),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // spacing between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Waktu: ",
                          style: const TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTime(seminar['datetime'], selectedZone),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedZone,
                decoration: _inputDecoration("Pilih Zona Waktu"),
                items: const [
                  DropdownMenuItem(
                    value: "WIB",
                    child: Text("Waktu Indonesia Barat (WIB)"),
                  ),
                  DropdownMenuItem(
                    value: "WITA",
                    child: Text("Waktu Indonesia Tengah (WITA)"),
                  ),
                  DropdownMenuItem(
                    value: "WIT",
                    child: Text("Waktu Indonesia Timur (WIT)"),
                  ),
                  DropdownMenuItem(value: "London", child: Text("London")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedZone = value!;
                  });
                },
              ),

              const SizedBox(height: 70),

              // Tombol daftar
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: const Text(
                  "Daftar Sekarang",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
    );
  }
}
