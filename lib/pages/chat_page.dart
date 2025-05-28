import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUsername;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUsername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  void sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': widget.currentUserId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Widget buildMessageBubble(Map<String, dynamic> messageData) {
    bool isMe = messageData['senderId'] == widget.currentUserId;
    final timestamp = messageData['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.grey[700] : Colors.grey[500],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(messageData['text']),
            if (timeString.isNotEmpty)
              Text(
                timeString,
                style: TextStyle(fontSize: 10, color: Colors.grey[900]),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    print('Current chatId: ${widget.chatId}');
    print('Current userId: ${widget.currentUserId}');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUsername),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Say hi 👋"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                    messages[index].data() as Map<String, dynamic>;

                    print('Message from ${messageData['senderId']}: ${messageData['text']}');

                    return buildMessageBubble(messageData);
                  },
                );
              },
            ),
          ),

          // Message input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
