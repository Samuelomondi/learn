import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // logout method
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.blueGrey,
        actions: [
          // logout button
          IconButton(
              onPressed: logout,
              icon: Icon(Icons.logout)
          )
        ],
      ),
    );
  }
}
