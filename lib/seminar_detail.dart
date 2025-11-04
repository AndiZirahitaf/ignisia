// file: /c:/Umar/UPNYK/Semester 5/Mobile/elearning/lib/seminar_detail.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api/api.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSeminarDetails();
    // Load seminar details from API or local data using widget.seminarId
  }

  String selectedZone = 'WIB';

  // Konversi zona waktu
  DateTime _convertToTimeZone(DateTime dateTime, String zone) {
    switch (zone) {
      case 'WITA':
        return dateTime.add(const Duration(hours: 1));
      case 'WIT':
        return dateTime.add(const Duration(hours: 2));
      case 'London':
        return dateTime.subtract(const Duration(hours: 7));
      default: // WIB
        return dateTime;
    }
  }

  Future<void> _loadSeminarDetails() async {
    final seminarDetails = await getSeminarDetail(widget.seminarId);
    setState(() {
      seminar = seminarDetails;
      _isLoading = false;
    });
  }

  // String _formatDate(DateTime dt) {
  //   final d = dt.toLocal();
  //   final two = (int n) => n.toString().padLeft(2, '0');
  //   final month = two(d.month);
  //   final day = two(d.day);
  //   final hour = two(d.hour);
  //   final minute = two(d.minute);
  //   return '$day/$month/${d.year} • $hour:$minute';
  // }

  // Format tanggal
  String _formatDate(DateTime dateTime, String zone) {
    final localized = _convertToTimeZone(dateTime, zone);
    final formatter = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id_ID');
    return "${formatter.format(localized)} $zone";
  }

  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registered for "${seminar['title']}".')),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(seminar['datetime']);

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Seminar Detail'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Replace with real share logic if needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share action (not implemented)'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Image
                  // SizedBox(
                  //   height: 220,
                  //   width: double.infinity,
                  //   child: _isLoading
                  //       ? Center(child: CircularProgressIndicator())
                  //       : Image.network(
                  //           seminar['image_url'],
                  //           fit: BoxFit.cover,
                  //           errorBuilder: (context, error, stackTrace) {
                  //             return Container(
                  //               color: Colors.grey.shade300,
                  //               alignment: Alignment.center,
                  //               child: const Icon(
                  //                 Icons.image_not_supported,
                  //                 size: 48,
                  //               ),
                  //             );
                  //           },
                  //         )

                  // ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title and speaker
                        Text(
                          seminar['title'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Text(
                        //   'Speaker: ${seminar['speaker']}',
                        //   // style: Theme.of(context).textTheme.subtitle1,
                        // ),
                        const SizedBox(height: 12),
                        // Pilihan zona waktu
                        Row(
                          children: [
                            const Text(
                              "Zona Waktu: ",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: selectedZone,
                              items: const [
                                DropdownMenuItem(
                                  value: 'WIB',
                                  child: Text('WIB'),
                                ),
                                DropdownMenuItem(
                                  value: 'WITA',
                                  child: Text('WITA'),
                                ),
                                DropdownMenuItem(
                                  value: 'WIT',
                                  child: Text('WIT'),
                                ),
                                DropdownMenuItem(
                                  value: 'London',
                                  child: Text('London'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedZone = value!;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Tampilkan waktu sesuai zona
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatDate(dateTime, selectedZone),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description (expandable)
                        Text(
                          'Description',
                          // style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          //   fontWeight: FontWeight.w600,
                          // ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _expandedDescription
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Text(
                            seminar['title'],
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          secondChild: Text(seminar['title']),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(
                              () =>
                                  _expandedDescription = !_expandedDescription,
                            ),
                            child: Text(
                              _expandedDescription ? 'Show less' : 'Read more',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Register button
                        ElevatedButton.icon(
                          onPressed: _register,
                          icon: const Icon(Icons.event_available),
                          label: const Text('Register'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Additional actions
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Add to calendar (not implemented)',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.calendar_month),
                              label: const Text('Add to Calendar'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Contact organizer (not implemented)',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.contact_mail),
                              label: const Text('Contact'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

// Example usage:
// Navigator.push(context, MaterialPageRoute(builder: (_) => SeminarDetailPage(
//   seminar: Seminar(
//     id: 's1',
//     title: 'Modern Mobile UX Patterns',
//     speaker: 'Dr. Jane Doe',
//     dateTime: DateTime.now().add(const Duration(days: 5, hours: 18)),
//     location: 'Room 201, Main Building',
//     imageUrl: 'https://example.com/seminar.jpg',
//     description: 'An in-depth look at modern mobile user experience patterns...',
//   ),
// )));
