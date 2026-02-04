/*

On this page a user can log in with their:
-email
-password

------------------------------------------------------------------------------------------------------------------------------------------

Once the user successfully logs in, they wil be redirected to the homepage

If the user does not have an account, they can go to the register page to create one


*/

import 'package:flutter/material.dart';
import 'package:flutter_1/features/auth/presentation/components/my_button.dart';
import 'package:flutter_1/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //auth cubit
  late final authCubit = context.read<AuthCubit>();

  //login button pressed
  void login() {
    //prepare data
    final String email = emailController.text;
    final String password = passwordController.text;

    //ensure that the fields are filled
    if (email.isNotEmpty && password.isNotEmpty) {
      //login
      authCubit.login(email, password);
    }
    //fields are empty
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields")),
      );
    }
  }

  //forgot password box
  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password?"),
        content: MyTextfield(
          controller: emailController,
          hintText: "Enter email..",
          obscureText: false,
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          //reset button
          TextButton(
            onPressed: () async {
              String message = await authCubit.forgotPassword(
                emailController.text,
              );

              if (message == "Password reset email sent! Check your inbox.") {
                Navigator.pop(context);
                emailController.clear();
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  //BUID UI
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    //SCAFFOLD
    return Scaffold(
      //BODY
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(Icons.lock_open, size: 80, color: colors.primary),

              const SizedBox(height: 25),

              //name of app
              Text(
                "G A W A",
                style: TextStyle(fontSize: 16, color: colors.primary),
              ),

              const SizedBox(height: 25),

              //email textfield
              MyTextfield(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),

              SizedBox(height: 10),

              //password textfield
              MyTextfield(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),

              const SizedBox(height: 10),
              //forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => openForgotPasswordBox(),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //login button
              MyButton(onTap: login, text: "Login"),

              //oauth
              SizedBox(height: 25),

              //dont have an account - register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dont have an account? ",
                    style: TextStyle(color: colors.primary),
                  ),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
