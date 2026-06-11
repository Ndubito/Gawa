import 'package:flutter_1/features/auth/domain/entities/user_model.dart';

abstract class ProfileRepo {
  Future<UserModel> getProfile(int userId);
  Future<UserModel> updateProfile(int userId, UserModel user);
  Future<void> deleteProfile(int userId);
}
