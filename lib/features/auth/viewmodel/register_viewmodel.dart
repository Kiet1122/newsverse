import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<User?> register(String email, String password) async {
    isLoading = true;
    notifyListeners();
    final user = await _authService.signUp(email, password);
    isLoading = false;
    notifyListeners();
    return user;
  }
}
