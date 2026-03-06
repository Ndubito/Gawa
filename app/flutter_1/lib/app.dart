import 'package:flutter/material.dart';
import 'package:flutter_1/features/auth/data/firebase_auth_repo.dart';
import 'package:flutter_1/features/auth/presentation/components/loading.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_state.dart';
import 'package:flutter_1/features/auth/presentation/pages/input_phone_number.dart';
import 'package:flutter_1/features/auth/presentation/pages/login_page_phone.dart';

import 'package:flutter_1/features/navigation/main_scaffold.dart';
import 'package:flutter_1/themes/dark_mode.dart';
import 'package:flutter_1/themes/light_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  App({super.key});

  //auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //provide cubits to app
      providers: [
        //auth cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gawa',
        theme: lightMode,
        darkTheme: darkMode,
        /*

          BLOC CONSUMER - Auth

        */
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            //unauthenticated -> auth page (Register/Login)
            if (state is Unauthenticated) {
              return const InputPhoneNumber();
            }

            //authenticated - Home Page
            if (state is Authenticated) {
              return const MainScaffold();
            }
            //code sent
            if (state is CodeSent) {
              return LoginPagePhone(verificatonId: state.verificationId,);
            }
            //wrong OTP code
            if(state is WrongOtp){
              return LoginPagePhone(verificatonId: state.verificationId);
            }
            // loading...
            else {
              return const LoadingScreen();
            }
          },
          //listen for state changes
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }
}
