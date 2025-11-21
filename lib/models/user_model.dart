import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'user' | 'journalist' | 'admin'
  final String? avatarUrl;
  final List<String> favoriteCategories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.favoriteCategories,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
    required this.preferences,
  });

  // Tạo object từ Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      avatarUrl: data['avatarUrl'],
      favoriteCategories: List<String>.from(data['favoriteCategories'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      preferences: data['preferences'] ?? {},
    );
  }

  // Chuyển object thành Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'favoriteCategories': favoriteCategories,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'preferences': preferences,
    };
  }
}