import 'package:flutter/material.dart';
import 'package:flutter_1/features/auth/presentation/components/my_button.dart';
import 'package:flutter_1/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  final Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final emailController = TextEditingController();
  final nameController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //register button pressed
  void register() {
    //prepare info
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();
    

    //ensure fields aren't empty
    if (email.isNotEmpty &&
        name.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      //ensure passwords match
      if (password == confirmPassword) {
        authCubit.register(email, password, name);
      }
      //paswwords don't match
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
      }
    }
    //fields are empty => display error
    else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please complete all fields!")));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                "Lets create and account for you",
                style: TextStyle(fontSize: 16, color: colors.primary),
              ),

              const SizedBox(height: 25),

              //username textfield
              MyTextfield(
                controller: nameController,
                hintText: "Name",
                obscureText: false,
              ),

              const SizedBox(height: 10),

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

              SizedBox(height: 10),

              //confirm password textfield
              MyTextfield(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                obscureText: true,
              ),

              const SizedBox(height: 20),

              //login button
              MyButton(onTap: register, text: "Sign Up"),

              //oauth
              SizedBox(height: 25),

              //dont have an account - register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: colors.primary),
                  ),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      "Login now",
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
