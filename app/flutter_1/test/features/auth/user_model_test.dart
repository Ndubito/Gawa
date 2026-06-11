import 'package:flutter_1/core/enums.dart';
import 'package:flutter_1/features/auth/domain/entities/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses a /users/me response', () {
      final user = UserModel.fromJson({
        'id': 7,
        'fullName': 'Nathan',
        'email': 'nathan@example.com',
        'phoneNumber': '+254700000001',
        'status': 'ACTIVE',
      });

      expect(user.id, 7);
      expect(user.fullName, 'Nathan');
      expect(user.email, 'nathan@example.com');
      expect(user.phoneNumber, '+254700000001');
      expect(user.status, UserStatus.active);
    });

    test('fromJson accepts a null email', () {
      final user = UserModel.fromJson({
        'id': 8,
        'fullName': '+254700000002',
        'email': null,
        'phoneNumber': '+254700000002',
        'status': 'ACTIVE',
      });

      expect(user.email, isNull);
    });

    test('toJson omits a null email', () {
      const user = UserModel(
        id: 9,
        fullName: 'Mary',
        phoneNumber: '+254700000003',
        status: UserStatus.active,
      );

      final json = user.toJson();
      expect(json.containsKey('email'), isFalse);
      expect(json['fullName'], 'Mary');
      expect(json['phoneNumber'], '+254700000003');
    });
  });
}
