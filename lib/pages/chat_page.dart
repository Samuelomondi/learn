import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String currentUserEmail;
  final String otherUserEmail;

  const ChatPage({
    super.key,
    required this.currentUserEmail,
    required this.otherUserEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  String? currentUserId;
  String? otherUserId;
  String? otherUsername;
  String? chatId;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<String?> getUidFromEmail(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching UID for $email: $e');
      return null;
    }
  }

  Future<String?> getUsernameByUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['username'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching username for UID $uid: $e');
      return null;
    }
  }

  Future<void> _initializeChat() async {
    setState(() => loading = true);

    final uid1 = await getUidFromEmail(widget.currentUserEmail);
    final uid2 = await getUidFromEmail(widget.otherUserEmail);

    if (uid1 == null || uid2 == null) {
      debugPrint('One or both users not found!');
      setState(() => loading = false);
      return;
    }

    final username2 = await getUsernameByUid(uid2);

    final orderedUids = [uid1, uid2]..sort();
    final generatedChatId = '${orderedUids[0]}-${orderedUids[1]}';

    setState(() {
      currentUserId = uid1;
      otherUserId = uid2;
      otherUsername = username2 ?? widget.otherUserEmail;
      chatId = generatedChatId;
      loading = false;
    });

    // Reset unread count for current user
    FirebaseFirestore.instance.collection('chats').doc(generatedChatId).set({
      'unreadCounts.${widget.currentUserEmail}': 0,
    }, SetOptions(merge: true));

    // Mark all unread messages as read immediately
    final batch = FirebaseFirestore.instance.batch();
    final messagesQuery = await FirebaseFirestore.instance
        .collection('chats')
        .doc(generatedChatId)
        .collection('messages')
        .where('receiverId', isEqualTo: uid1)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in messagesQuery.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || chatId == null || currentUserId == null || otherUserId == null) return;

    final timestamp = FieldValue.serverTimestamp();

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'receiverId': otherUserId,
        'text': text,
        'timestamp': timestamp,
        'read': false,
      });

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set({
        'lastMessage': text,
        'lastMessageTimestamp': timestamp,
        'participants': [widget.currentUserEmail, widget.otherUserEmail],
        'unreadCounts.${widget.otherUserEmail}': FieldValue.increment(1),
      }, SetOptions(merge: true));

      _messageController.clear();
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final time = TimeOfDay.fromDateTime(dt).format(context);
    return time;
  }

  Widget buildMessageBubble(Map<String, dynamic> data) {
    final isMe = data['senderId'] == currentUserId;
    final text = data['text'] ?? '';
    final time = formatTimestamp(data['timestamp'] as Timestamp?);
    final read = data['read'] == true;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.grey[400] : Colors.grey[500],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[900])),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      read ? Icons.done_all : Icons.check,
                      size: 16,
                      color: read ? Colors.black : Colors.black45,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (chatId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Error initializing chat. Users not found.')),
      );
    }

    final messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            otherUsername ?? 'Chat',
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet. Say hi! 👋"));
                }

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;

                    if (!messageData.containsKey('senderId') || !messageData.containsKey('text')) {
                      return const SizedBox.shrink();
                    }

                    return buildMessageBubble(messageData);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
