import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/chat_page.dart';

import '../components/my_back_button.dart';

class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final currentUserEmail = currentUser.email ?? '';

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserEmail)
            .orderBy('lastMessageTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          final chatDocs = snapshot.data!.docs;

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50, left: 10),
                child: Row(children: [MyBackButton()]),
              ),
              const Text(
                "C H A T S",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    final chatDoc = chatDocs[index];
                    final data = chatDoc.data() as Map<String, dynamic>;
                    final participants = List<String>.from(data['participants'] ?? []);
                    final lastMessage = data['lastMessage'] ?? '';
                    final timestamp = data['lastMessageTimestamp'] as Timestamp?;
                    final unreadCounts = Map<String, dynamic>.from(data['unreadCounts'] ?? {});
                    final unreadCount = unreadCounts[currentUserEmail] ?? 0;

                    final time = timestamp != null
                        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
                        : '';

                    final otherUserEmail = participants.firstWhere(
                          (email) => email != currentUserEmail,
                      orElse: () => '',
                    );

                    if (otherUserEmail.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .where("email", isEqualTo: otherUserEmail)
                          .limit(1)
                          .get()
                          .then((query) {
                        if (query.docs.isNotEmpty) {
                          return query.docs.first.reference.get();
                        } else {
                          return Future.value(null);
                        }
                      }),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData || userSnapshot.data == null) {
                          return const SizedBox.shrink();
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        final username = userData['username'] ?? 'Unknown';

                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                username,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              subtitle: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    time,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  if (unreadCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      currentUserEmail: currentUserEmail,
                                      otherUserEmail: otherUserEmail,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
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
