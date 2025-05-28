// UsersPage
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/components/my_back_button.dart';
import 'package:chat/components/my_list_tile.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/helper/helper_function.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
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
            ..sort((a, b) => a['username'].compareTo(b['username']));

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50, left: 10),
                child: Row(children: [MyBackButton()]),
              ),
              const Text("U S E R S", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final username = user['username'];
                    final email = user['email'];
                    final otherUserId = user.id;
                    final chatId = getChatId(currentUserId, otherUserId);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: chatId,
                              currentUserId: currentUserId,
                              otherUsername: username,
                              otherUserId: otherUserId,
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
