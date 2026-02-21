import 'package:flutter/material.dart';
import 'package:flutter_1/features/auth/presentation/components/my_button.dart';
import 'package:flutter_1/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InputPhoneNumber extends StatefulWidget {
  const InputPhoneNumber({super.key});

  @override
  State<InputPhoneNumber> createState() => _InputPhoneNumberState();
}

class _InputPhoneNumberState extends State<InputPhoneNumber> {
  //text controllers
  final phoneNumberController = TextEditingController();

  //register button pressed
  void sendOtp() {
    //prepare info
    final String phoneNumber = phoneNumberController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    //ensure field isn't empty
    if (phoneNumber.isNotEmpty) {
      //send the otp
        authCubit.sendOtp(phoneNumber);
      }
    //field is empty => display error
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields!")),
      );
    }
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
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
                "Lets create an account for you",
                style: TextStyle(fontSize: 16, color: colors.primary),
              ),

              const SizedBox(height: 25),

              //username textfield
              MyTextfield(
                controller: phoneNumberController,
                hintText: "Phone Number",
                obscureText: false,
              ),

              const SizedBox(height: 20),

              //login button
              MyButton(onTap: sendOtp, text: "Continue"),

              //oauth
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
