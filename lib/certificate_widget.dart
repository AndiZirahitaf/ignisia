// certificate_widget.dart

import 'package:flutter/material.dart';

class CertificateDesign extends StatelessWidget {
  final String courseName;
  final String userName;
  final DateTime completedDate;
  final String signerName; // Nama untuk tanda tangan

  const CertificateDesign({
    required this.courseName,
    required this.userName,
    required this.completedDate,
    required this.signerName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800, // Lebar ideal untuk sertifikat (rasio 4:3 atau 3:2)
      height: 600, // Tinggi ideal
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent.shade100, width: 10),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. HEADER
          const Text(
            'CERTIFICATE OF COMPLETION',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),

          // 2. CONTENT UTAMA
          Column(
            children: [
              const Text(
                'This certifies that',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
              // NAMA USER
              Text(
                userName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontFamily: 'Serif', // Gunakan font yang formal
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'has successfully completed the course',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
              // NAMA COURSE
              Text(
                courseName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),

          // 3. FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TANGGAL SELESAI
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Completed:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    '${completedDate.day}/${completedDate.month}/${completedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // TANDA TANGAN
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '____________________________',
                  ), // Garis Tanda Tangan
                  const SizedBox(height: 5),
                  Text(
                    signerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    'Instructor/Platform Admin',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
