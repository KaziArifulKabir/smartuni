import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SmartUniApp());
}

class SmartUniApp extends StatelessWidget {
  const SmartUniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "SmartUni Companion",

      theme: AppTheme.lightTheme,

      home: const LoginScreen(),
    );
  }
}