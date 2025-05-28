import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chat_page.dart';


class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat.jm().format(date); // Example: 5:23 PM
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("chats"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats yet."));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final chatId = chatDoc.id;
              final participants = List<String>.from(chatDoc['participants']);
              final otherUserId =
              participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final otherUsername = userSnapshot.data!['username'];

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      String lastMessage = "Say hi 👋";
                      String time = "";

                      if (messageSnapshot.hasData &&
                          messageSnapshot.data!.docs.isNotEmpty) {
                        final message =
                        messageSnapshot.data!.docs.first.data()
                        as Map<String, dynamic>;
                        lastMessage = message['text'];
                        time = formatTimestamp(message['timestamp']);
                      }

                      return ListTile(
                        title: Text(otherUsername),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(time),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                chatId: chatId,
                                currentUserId: currentUserId,
                                otherUsername: otherUsername,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
