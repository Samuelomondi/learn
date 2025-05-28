import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat/auth/auth.dart';
import 'package:chat/auth/login_or_register.dart';
import 'package:chat/firebase_options.dart';
import 'package:chat/pages/home_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/users_page.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/theme/dark_mode.dart';
import 'package:chat/theme/light_mode.dart';

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
      routes: {
        '/login_register_page':(context) => const LoginOrRegister(),
        '/home_page':(context) => HomePage(),
        '/chats_page':(context) => ChatsPage(),
        '/profile_page':(context) => ProfilePage(),
        '/users_page':(context) => UsersPage(),
      },
    );
  }
}
