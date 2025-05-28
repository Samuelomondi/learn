import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/components/my_button.dart';
import 'package:chat/components/my_textfield.dart';

import '../helper/helper_function.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;


  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController = TextEditingController();

  void registerUser() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
    );

    // make sure passwords match
    if (passwordController.text != confirmPasswordController.text) {
      if (context.mounted) {
        // pop loading circle
        Navigator.pop(context);
        // show error
        displayMessageToUser("Passwords don't match", context);
      }
    } else {
      // try creating the user
      try {
        // create the user
        UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );

        // create a user document to add to firestore
        await createUserDocument(userCredential);

        // pop loading circle
        if (context.mounted) {
          Navigator.pop(context);
        }

      } on FirebaseAuthException catch (e) {
        // remove loading indicator
        if (context.mounted) {
          Navigator.pop(context);
          displayMessageToUser(e.code, context);
        }
      }
    }
  }

  // create a user document and collect them in firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .set({
            'email': userCredential.user!.email,
            'username': usernameController.text,
          });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25,),
        
                //app name
                const Text(
                  'M I N I M A L',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 50,),
        
                // username text field
                MyTextField(
                    hintText: "Username",
                    obscureText: false,
                    controller: usernameController,
                ),
                const SizedBox(height: 10,),
        
                // email text field
                MyTextField(
                    hintText: "Email Address",
                    obscureText: false,
                    controller: emailController
                ),
                const SizedBox(height: 10,),
        
                // password text field
                MyTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController
                ),
                const SizedBox(height: 10,),
        
                // confirm password text field
                MyTextField(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPasswordController
                ),
                const SizedBox(height: 25,),
        
                // register button
                MyButton(
                  text: "Register",
                  onTap: registerUser,
                ),
                const SizedBox(height: 25,),
        
                // register button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Login here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
