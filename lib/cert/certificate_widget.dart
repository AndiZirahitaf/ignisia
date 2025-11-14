import 'package:elearning/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CertificateDesign extends StatelessWidget {
  final String courseName;
  final String userName;
  final DateTime completedDate;

  const CertificateDesign({
    super.key,
    required this.courseName,
    required this.userName,
    required this.completedDate,
  });

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    final String formattedDate = DateFormat(
      'd MMMM yyyy',
    ).format(completedDate);

    return Container(
      width: 350,
      height: 248,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'lib/assets/cert_frame.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Column(
              children: [
                Column(
                  children: [
                    Text(
                      'Ignisia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(height: 0.5, width: 40, color: Colors.grey[700]),
                    const SizedBox(height: 5),
                    Text(
                      'CERTIFICATE OF COMPLETION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 46, 75, 118),
                      ),
                    ),

                    const SizedBox(height: 5),
                    const Text(
                      'IS PROUDLY PRESENTED TO',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 6, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Trocchi',
                        fontSize: 19,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF0D47A1),
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'For successfully completing the course',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '"$courseName"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black87,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Issued on $formattedDate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Image.asset(
                      'lib/assets/ttd.png',
                      height: 35,
                      fit: BoxFit.fitHeight,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Umar Andika Fatihariz',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      'Chief Executive Officer',
                      style: TextStyle(fontSize: 7, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
