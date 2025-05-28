import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/components/my_back_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // current logged in user
  User? currentUser = FirebaseAuth.instance.currentUser;

  // future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance.collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder(
          future: getUserDetails(),
          builder: (context, snapshot) {
            // loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // error
            else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            // data received
            else if (snapshot.hasData) {
              // extract data
              Map<String, dynamic>? user = snapshot.data!.data();

              return Center(
                child: Column(
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
                    const SizedBox(height: 25,),

                    // profile pic
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24)
                      ),
                      padding: const EdgeInsets.all(25),
                      child: const Icon(
                          Icons.person,
                          size: 64 ,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // username
                    Text(
                        user!['username'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        ),
                    ),

                    // email
                    Text(
                        user['email'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                    ),
                  ],
                ),
              );
            }
            // if empty
            else {
              return const Text("No data");
            }
          },
      ),
    );
  }
}
