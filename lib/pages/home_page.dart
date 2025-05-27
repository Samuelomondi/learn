import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/components/my_drawer.dart';
import 'package:learn/components/my_post_button.dart';
import 'package:learn/components/my_textfield.dart';
import 'package:learn/database/firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // firestore access
  final FirestoreDatabase database = FirestoreDatabase();


  final TextEditingController newPostController = TextEditingController();

  // post message
  void postMessage() {
    // only post if there is something in the text field
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    // clear the text field
    newPostController.clear();
  }

  // time display
  String formatTimestamp(Timestamp timestamp) {
    DateTime dt = timestamp.toDate();

    String day = dt.day.toString().padLeft(2, '0');
    String month = dt.month.toString().padLeft(2, '0');
    String year = dt.year.toString().substring(2); // Get last 2 digits
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');

    return "$day/$month/$year - $hour:$minute";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
            "W A L L",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
            ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.inversePrimary),
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          // text field for user to type
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                // text field
                Expanded(
                  child: MyTextField(
                      hintText: "Say something...",
                      obscureText: false,
                      controller: newPostController,
                  ),
                ),

                // post button
                MyPostButton(
                  onTap: postMessage,
                ),
              ],
            ),
          ),

          // reading posts
          StreamBuilder(
              stream: database.getPostsStream(),
              builder: (context, snapshot) {
                // show loading circle
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                //get all posts
                final posts = snapshot.data!.docs;
                
                // no data?
                if (snapshot.data == null || posts.isEmpty) {
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: const Text("No posts.. Post something!"),
                      )
                  );
                }

                // return as a list
                return Expanded(
                    child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          // get each individual post
                          final post = posts[index];
                          
                          // get data from each post
                          String message = post['PostMessage'];
                          String userEmail = post['UserEmail'];
                          Timestamp timestamp = post['Timestamp'];
                          
                          // return as a list
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: ListTile(
                                title: Text(
                                    message,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                    userEmail,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                trailing: Text(
                                  formatTimestamp(timestamp),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                );
              },
          ),
        ],
      ),
    );
  }
}
