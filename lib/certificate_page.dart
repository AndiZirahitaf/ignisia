// certificate_generator_page.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:elearning/certificate_widget.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Import widget desain yang sudah dibuat
// import 'certificate_widget.dart';

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  // 1. Deklarasi ScreenshotController
  final ScreenshotController _screenshotController = ScreenshotController();

  // Data dummy (ganti dengan data actual dari course)
  final String _courseName = "Advance Flutter UI/UX Development";
  final String _userName = "Budi Hartono";
  final DateTime _completedDate = DateTime.now();
  final String _signerName = "Fulan bin Fulan";

  // 2. Fungsi untuk Meng-capture dan Menyimpan Gambar
  Future<void> _captureAndSaveCertificate() async {
    // 2.1. Meminta Izin Penyimpanan
    if (await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating certificate...')),
      );

      // 2.2. Melakukan capture (merender widget menjadi Unit8List)
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0, // Resolusi lebih tinggi (opsional)
      );

      if (imageBytes != null) {
        // 2.3. Menentukan Direktori Penyimpanan
        final directory = await getApplicationDocumentsDirectory();

        // Di Android, gunakan getExternalStorageDirectory atau getDownloadsDirectory untuk akses yang lebih mudah
        // Contoh untuk Android/iOS
        final String path = Platform.isAndroid
            ? (await getExternalStorageDirectory())?.path ?? directory.path
            : directory.path;

        final fileName =
            'certificate_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('$path/$fileName');

        // 2.4. Menulis Bytes ke File
        await file.writeAsBytes(imageBytes);

        // 2.5. Beri notifikasi ke user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sertifikat berhasil di-download ke: $path/$fileName',
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      // Handle jika izin ditolak
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan ditolak.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Sertifikat"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3. Membungkus CertificateDesign dengan ScreenshotController
              Screenshot(
                controller: _screenshotController,
                child: CertificateDesign(
                  courseName: _courseName,
                  userName: _userName,
                  completedDate: _completedDate,
                  signerName: _signerName,
                ),
              ),

              const SizedBox(height: 40),

              // 4. Tombol Download PNG
              ElevatedButton.icon(
                onPressed: _captureAndSaveCertificate,
                icon: const Icon(Icons.download),
                label: const Text('Download Sertifikat (PNG)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
