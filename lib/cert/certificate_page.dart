import 'dart:io';
import 'dart:typed_data';

import 'package:elearning/app_theme.dart';
import 'package:elearning/cert/certificate_widget.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class CertificatePage extends StatefulWidget {
  final String courseName;
  final String userName;
  final DateTime completedDate;

  const CertificatePage({
    super.key,
    required this.courseName,
    required this.userName,
    required this.completedDate,
  });

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  Future<void> _captureAndSaveCertificate() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating certificate...')),
      );

      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception("Gagal membuat screenshot sertifikat.");
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      final fileName =
          'certificate_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('$path/$fileName');

      await file.writeAsBytes(imageBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sertifikat tersimpan di: $path/$fileName'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Buka',
              onPressed: () => OpenFile.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sertifikat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Screenshot(
                controller: _screenshotController,
                child: CertificateDesign(
                  courseName: widget.courseName,
                  userName: widget.userName,
                  completedDate: widget.completedDate,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _captureAndSaveCertificate,
                icon: const Icon(Icons.download),
                label: const Text('Download Sertifikat (PNG)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 19, 85, 165),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
