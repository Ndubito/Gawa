/*
  Auth States
*/

import 'package:flutter_1/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

//initial
class AuthInitial extends AuthState{}

//loading
class AuthLoading extends AuthState{}

//authenticated
class Authenticated extends AuthState{
  final AppUser? user;
  Authenticated(this.user);
}

class WrongOtp extends AuthState{
  final String verificationId;
  WrongOtp(this.verificationId);
}

//unauthenticated
class Unauthenticated extends AuthState{}

//OTP code sent for mobile login
class CodeSent extends AuthState{
  final String verificationId;
  CodeSent(this.verificationId);
}

//errors
class AuthError extends AuthState{
  final String message;

  AuthError(this.message);
}


