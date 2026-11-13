import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const SmartUniApp(),
  );
}
class SmartUniApp extends StatelessWidget {
  const SmartUniApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:
      "SmartUni Companion",
      theme:
      AppTheme.lightTheme,
      home:
      const LoginScreen(),
    );
  }
}