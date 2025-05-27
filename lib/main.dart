import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn/auth/auth.dart';
import 'package:learn/firebase_options.dart';
import 'package:learn/theme/dark_mode.dart';
import 'package:learn/theme/light_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
