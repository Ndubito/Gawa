/*

On this page a user can log in with their:
-OTP Code sent after they have input their phone number

------------------------------------------------------------------------------------------------------------------------------------------

Once the user successfully logs in, they wil be redirected to the homepage

If the user does not have an account, it will be created for them (they will then be taken to another page which will ask for
additional information), otherwise they will just be logged in

*/

import 'package:flutter/material.dart';
import 'package:flutter_1/features/auth/presentation/components/my_button.dart';
import 'package:flutter_1/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPagePhone extends StatefulWidget {

  final String verificatonId;

  const LoginPagePhone({super.key, required this.verificatonId});

  @override
  State<LoginPagePhone> createState() => _LoginPagePhoneState();
}

class _LoginPagePhoneState extends State<LoginPagePhone> {
  //text controllers
  final otpController = TextEditingController();

  //auth cubit
  late final authCubit = context.read<AuthCubit>();

  //verify code button pressed
  void verifyCode() {
    //prepare data
    final String otp = otpController.text;

    //ensure that the fields are filled
    if (otp.isNotEmpty) {
      //login
      authCubit.verifyOtp(widget.verificatonId, otp);
    }
    //fields are empty
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields")),
      );
    }
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

              //otp textfield
              MyTextfield(
                controller: otpController,
                hintText: "OTP Code",
                obscureText: false,
              ),

              SizedBox(height: 10),

              const SizedBox(height: 20),

              //login button
              MyButton(onTap: verifyCode, text: "Verify Code"),

              //oauth
              SizedBox(height: 25),

            ],
          ),
        ),
      ),
    );
  }
}
