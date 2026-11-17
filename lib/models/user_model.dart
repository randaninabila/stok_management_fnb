
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  // Mengubah data Firestore menjadi UserModel.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      isActive: map['isActive'] == true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Mengubah UserModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
