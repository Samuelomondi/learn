import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // logout method
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // header
              DrawerHeader(
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 25),

              // home
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text(
                      "H O M E",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary
                      ),
                  ),
                  onTap: () {
                    // this is already home
                    Navigator.pop(context);
                  },
                ),
              ),

              // profile
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text(
                      "P R O F I L E",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary
                      ),
                  ),
                  onTap: () {
                    // pop drawer
                    Navigator.pop(context);

                    // navigate to profile page
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),

              // users
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.group,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text(
                      "U S E R S",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                  ),
                  onTap: () {
                    // pop drawer
                    Navigator.pop(context);

                    // navigate to users page
                    Navigator.pushNamed(context, '/users_page');
                  },
                ),
              ),

            ],
          ),

          // logout
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: Text(
                  "L O G O U T",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
              ),
              onTap: () {
                logout();
              },
            ),
          )
        ],
      ),
    );
  }
}
