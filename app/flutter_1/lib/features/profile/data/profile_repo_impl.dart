import 'package:flutter_1/features/auth/domain/entities/user_model.dart';
import 'package:flutter_1/features/profile/domain/repos/profile_repo.dart';

class ProfileRepoImpl extends ProfileRepo {
  // TODO: inject ApiClient

  @override
  Future<UserModel> getProfile(int userId) => throw UnimplementedError();

  @override
  Future<UserModel> updateProfile(int userId, UserModel user) => throw UnimplementedError();

  @override
  Future<void> deleteProfile(int userId) => throw UnimplementedError();
}
