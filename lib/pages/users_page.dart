import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/components/my_back_button.dart';
import 'package:chat/components/my_list_tile.dart';
import 'package:chat/helper/helper_function.dart';
import 'chat_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  // Helper to generate consistent chatId
  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          // Handle errors
          if (snapshot.hasError) {
            displayMessageToUser("Something went wrong", context);
            return const Center(child: Text("Error loading users"));
          }

          // Loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // No data case
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          // Exclude current user and sort
          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUserId)
              .toList()
            ..sort((a, b) => a['username'].compareTo(b['username']));

          return Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: Row(
                  children: const [
                    MyBackButton(),
                  ],
                ),
              ),

              const Text(
                "U S E R S",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              // User list
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final username = user['username'];
                    final email = user['email'];
                    final otherUserId = user.id;

                    return GestureDetector(
                      onTap: () async {
                        // Show loading spinner
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                        );

                        // Generate consistent chat ID
                        final chatId = getChatId(currentUserId, otherUserId);
                        final chatRef = FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chatId);

                        final chatSnapshot = await chatRef.get();

                        // Create chat if it doesn’t exist
                        if (!chatSnapshot.exists) {
                          await chatRef.set({
                            'participants': [currentUserId, otherUserId],
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }

                        // Close loading
                        Navigator.pop(context);

                        // Go to chat page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatId: chatId,
                              currentUserId: currentUserId,
                              otherUsername: username,
                            ),
                          ),
                        );
                      },
                      child: MyListTile(
                        title: username,
                        subTitle: email,
                      ),
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
