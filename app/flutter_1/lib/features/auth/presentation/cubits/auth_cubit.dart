/*
  Respinsible for state management
*/

import 'package:flutter/foundation.dart';
import 'package:flutter_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_1/features/auth/domain/entities/user_model.dart';
import 'package:flutter_1/features/auth/domain/repos/auth_repo.dart';
import 'package:flutter_1/features/auth/domain/repos/backend_user_repo.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final BackendUserRepo? backendUserRepo;
  AppUser? _currentUser;
  UserModel? _backendUser;

  AuthCubit({required this.authRepo, this.backendUserRepo})
      : super(AuthInitial());

  //get current user
  AppUser? get currentUser => _currentUser;

  //get the backend user row (integer id used by groups, payments, etc.)
  UserModel? get backendUser => _backendUser;

  //fetch (or create on first login) the backend user for this Firebase account
  Future<void> _syncBackendUser() async {
    if (backendUserRepo == null) return;
    try {
      _backendUser = await backendUserRepo!.getMe();
    } catch (e) {
      // The app stays usable offline; features needing the backend id
      // check backendUser themselves.
      _backendUser = null;
      debugPrint('Backend user sync failed: $e');
    }
  }

  //check if user is Authenticated
  void checkAuth() async {
    //loading
    emit(AuthLoading());

    //get current user
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      await _syncBackendUser();
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
        await _syncBackendUser();
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
        await _syncBackendUser();
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
      _currentUser = null;
      _backendUser = null;
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
      _currentUser = null;
      _backendUser = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  /*
    MOBILE LOGIN
  */

  // Send OTP
  Future<void> sendOtp(String phone) async {
    emit(AuthLoading());
    try {
      await authRepo.verifyPhoneNumber(
        phoneNumber: phone,
        codeSent: (verificationId) {
          emit(CodeSent(verificationId));
        },
        verificationFailed: (error) {
          emit(AuthError(error));
          emit(Unauthenticated());
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  //verify OTP
  Future<void> verifyOtp(String verificationId, String smsCode) async {
    try {
      emit(AuthLoading());

      final user = await authRepo.verifyOtp(verificationId, smsCode);

      if (user != null) {
        _currentUser = user;
        await _syncBackendUser();
        emit(Authenticated(user));
      } else {
        emit(AuthError("OTP verification failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(WrongOtp(verificationId));
    }
  }
}
