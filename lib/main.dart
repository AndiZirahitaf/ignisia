import 'package:elearning/app_theme.dart';
import 'package:elearning/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:elearning/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ignisia',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
