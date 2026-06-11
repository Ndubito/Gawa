import 'package:flutter_1/core/enums.dart';

class UserModel {
  final int id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final UserStatus status;

  const UserModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      status: UserStatus.fromString(json['status'] as String),
    );
  }

  /// Used for create and update request bodies.
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
      };
}
