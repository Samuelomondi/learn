import 'package:flutter/material.dart';
import 'package:learn/components/my_button.dart';
import 'package:learn/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key, required this.onTap});

  // login method
  void login() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
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
              
              // forgot password text
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary
                      )
                  ),
                ],
              ),
              const SizedBox(height: 25,),

              // sign in button
              MyButton(
                  text: "Login",
                  onTap: login,
              ),
              const SizedBox(height: 25,),

              // register button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Don't have an account? ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary
                      ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                        "Register here",
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
    );
  }


}
