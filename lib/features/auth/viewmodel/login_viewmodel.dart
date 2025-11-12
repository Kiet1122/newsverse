import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<User?> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    final user = await _authService.signIn(email, password);
    isLoading = false;
    notifyListeners();
    return user;
  }
}
