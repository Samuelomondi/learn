import 'package:flutter/material.dart';
import 'package:learn/auth/login_or_register.dart';
import 'package:learn/theme/dark_mode.dart';
import 'package:learn/theme/light_mode.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
