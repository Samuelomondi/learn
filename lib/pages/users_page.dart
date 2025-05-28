import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/components/my_back_button.dart';
import 'package:chat/components/my_list_tile.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/helper/helper_function.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }
    final currentUserId = currentUser.uid;
    final currentUserEmail = currentUser.email ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            displayMessageToUser("Something went wrong", context);
            return const Center(child: Text("Error loading users"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUserId)
              .toList()
            ..sort((a, b) => (a['username'] as String).compareTo(b['username'] as String));

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50, left: 10),
                child: Row(children: [MyBackButton()]),
              ),
              const Text(
                "U S E R S",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final username = user['username'] as String;
                    final email = user['email'] as String;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              currentUserEmail: currentUserEmail,
                              otherUserEmail: email,
                            ),
                          ),
                        );
                      },
                      child: MyListTile(title: username, subTitle: email),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
