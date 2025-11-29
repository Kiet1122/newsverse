import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firebase/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user; 
  bool _isLoading = false; 
  bool _isInitializing = true; 
  String? _error; 

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;

  /// Initialize authentication state listener
  void initialize() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
      }
      _isInitializing = false;
      notifyListeners(); 
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _user = await _authService.getUserData(uid);
      if (_user != null) {
        print('Load user data successful: ${_user?['email']}');
      } else {
        print('Unable to load user data');
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading user data: $e');
    }
    notifyListeners();
  }

  /// Register a new user account
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('Starting user registration: $email');

    try {
      _user = await _authService.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      
      _isLoading = false;
      print('Registration successful: ${_user?['email']}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      print('Registration error: $e');
      print('Error message: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      print('Login successful: ${_user?['email']}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      print('Login error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _error = null;
      print('Sign out successful');
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      print('Password reset email sent');
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      print('Password reset error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Clear any existing error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Convert Firebase authentication errors 
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email đã được sử dụng. Vui lòng chọn email khác.';
        case 'invalid-email':
          return 'Email không hợp lệ.';
        case 'operation-not-allowed':
          return 'Tính năng đăng ký tạm thời bị tắt.';
        case 'weak-password':
          return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        case 'user-disabled':
          return 'Tài khoản đã bị vô hiệu hóa.';
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này.';
        case 'wrong-password':
          return 'Mật khẩu không đúng.';
        case 'too-many-requests':
          return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        default:
          return 'Lỗi xác thực: ${error.message}';
      }
    } else if (error is FirebaseException) {
      return 'Lỗi Firebase: ${error.message}';
    }
    return error.toString();
  }
}