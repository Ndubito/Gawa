import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_1/features/auth/domain/entities/user_model.dart';
import 'package:flutter_1/features/auth/domain/repos/auth_repo.dart';
import 'package:flutter_1/features/auth/domain/repos/backend_user_repo.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_1/features/auth/presentation/cubits/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake auth repo: pretends a Firebase user is (or isn't) signed in.
class FakeAuthRepo extends AuthRepo {
  final AppUser? user;
  FakeAuthRepo({this.user});

  @override
  Future<AppUser?> getCurrentUser() async => user;

  @override
  Future<AppUser?> verifyOtp(String verificationId, String smsCode) async =>
      user;

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<AppUser?> registerWithEmailPassword(
          String name, String email, String password) =>
      throw UnimplementedError();

  @override
  Future<String> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAccount() => throw UnimplementedError();

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) =>
      throw UnimplementedError();
}

/// Fake backend user repo returning a fixed user or failing.
class FakeBackendUserRepo extends BackendUserRepo {
  final UserModel? me;
  FakeBackendUserRepo({this.me});

  @override
  Future<UserModel> getMe() async {
    if (me == null) throw Exception('backend unreachable');
    return me!;
  }
}

void main() {
  final appUser = AppUser(uid: 'uid-1', phone: '+254700000001');
  const backendUser = UserModel(
    id: 1,
    fullName: '+254700000001',
    phoneNumber: '+254700000001',
    status: UserStatus.active,
  );

  group('AuthCubit backend user sync', () {
    test('checkAuth fetches the backend user when authenticated', () async {
      final cubit = AuthCubit(
        authRepo: FakeAuthRepo(user: appUser),
        backendUserRepo: FakeBackendUserRepo(me: backendUser),
      );

      cubit.checkAuth();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<Authenticated>());
      expect(cubit.backendUser, isNotNull);
      expect(cubit.backendUser!.id, 1);
    });

    test('stays authenticated when the backend sync fails', () async {
      final cubit = AuthCubit(
        authRepo: FakeAuthRepo(user: appUser),
        backendUserRepo: FakeBackendUserRepo(me: null),
      );

      cubit.checkAuth();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<Authenticated>());
      expect(cubit.backendUser, isNull);
    });

    test('verifyOtp syncs the backend user after login', () async {
      final cubit = AuthCubit(
        authRepo: FakeAuthRepo(user: appUser),
        backendUserRepo: FakeBackendUserRepo(me: backendUser),
      );

      await cubit.verifyOtp('verification-id', '123456');

      expect(cubit.state, isA<Authenticated>());
      expect(cubit.backendUser!.id, 1);
    });

    test('logout clears the backend user', () async {
      final cubit = AuthCubit(
        authRepo: FakeAuthRepo(user: appUser),
        backendUserRepo: FakeBackendUserRepo(me: backendUser),
      );

      await cubit.verifyOtp('verification-id', '123456');
      expect(cubit.backendUser, isNotNull);

      await cubit.logout();
      expect(cubit.state, isA<Unauthenticated>());
      expect(cubit.backendUser, isNull);
      expect(cubit.currentUser, isNull);
    });

    test('works without a backend user repo (not provided)', () async {
      final cubit = AuthCubit(authRepo: FakeAuthRepo(user: appUser));

      cubit.checkAuth();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<Authenticated>());
      expect(cubit.backendUser, isNull);
    });
  });
}
