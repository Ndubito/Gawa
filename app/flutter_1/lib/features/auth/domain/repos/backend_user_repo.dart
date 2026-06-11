/*
BACKEND USER REPOSITORY - Resolves the Firebase-authenticated user to the
backend's User row (the integer id used by groups, obligations, payments...).
*/

import 'package:flutter_1/features/auth/domain/entities/user_model.dart';

abstract class BackendUserRepo {
  /// Fetches (creating/linking on first login) the backend user
  /// for the currently signed-in Firebase account.
  Future<UserModel> getMe();
}
