/*

This database stores post that users have published
It is stored in a collection called 'Posts' in Firestore

Each post will have:
- message
- email
- timestamp

 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  // current logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // collection of posts
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  // post a message
  Future<void> addPost(String message) {
    return posts.add({
      'UserEmail':user!.email,
      'PostMessage':message,
      'Timestamp': Timestamp.now(),
    });
  }

  // read posts
  Stream<QuerySnapshot> getPostsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('Timestamp', descending: true)
        .snapshots();

    return postsStream;
  }
}