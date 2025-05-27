import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/components/my_back_button.dart';
import 'package:learn/components/my_list_tile.dart';
import 'package:learn/helper/helper_function.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          // any errors
          if (snapshot.hasError) {
            displayMessageToUser("Something went wrong", context);
          }
          
          // loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          // no users
          if (snapshot.data == null) {
            return const Text("No Data");
          }
          
          // get all users
          final users = snapshot.data!.docs;
          
          return Column(
            children: [
              // back button
              Padding(
                padding: const EdgeInsets.only(
                    top: 50,
                    left: 10
                ),
                child: Row(
                  children: [
                    MyBackButton(),
                  ],
                ),
              ),

              Text(
                  "U S E R S",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    // get individual user
                    final user = users[index];

                    // get data from each user
                    String username = user['username'];
                    String email = user['email'];

                    return MyListTile(title: username, subTitle: email);
                  }
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
