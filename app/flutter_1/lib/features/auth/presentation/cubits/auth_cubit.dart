/*
  Respinsible for state management
*/

import 'package:flutter_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_1/features/auth/domain/repos/auth_repo.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  //get current user
  AppUser? get currentUser => _currentUser;

  //check if user is Authenticated
  void checkAuth() async {
    //loading
    emit(AuthLoading());

    //get current user
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  //Login with email + password
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //register with email and password
  Future<void> register(String email, String password, String name) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(
        name,
        email,
        password,
      );
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //Logout
  Future<void> logout() async {
    try {
      emit(AuthLoading());
      await authRepo.logout();
      emit(Unauthenticated());
    } catch (e) {
      throw 'Cannot logout: $e';
    }
  }

  //Forgot password
  Future<String> forgotPassword(String email) async {
    try {
      final message = authRepo.sendPasswordResetEmail(email);
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  //Delete Account
  Future<void> deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}
