import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firebase/auth_service.dart';

// Provider quản lý trạng thái đăng nhập, đăng ký
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user; // Thông tin user hiện tại
  bool _isLoading = false; // Đang xử lý
  bool _isInitializing = true; // Đang khởi tạo
  String? _error; // Lỗi nếu có

  // Getter để truy cập từ bên ngoài
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;

  // Khởi tạo - lắng nghe thay đổi trạng thái đăng nhập
  void initialize() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Có user đăng nhập, load thông tin
        await _loadUserData(firebaseUser.uid);
      } else {
        // Không có user, set về null
        _user = null;
      }
      _isInitializing = false;
      notifyListeners(); // Thông báo cho UI cập nhật
    });
  }

  // Load thông tin user từ Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _user = await _authService.getUserData(uid);
      if (_user != null) {
        print('Load user data thành công: ${_user?['email']}');
      } else {
        print('Không thể load user data');
      }
    } catch (e) {
      _error = e.toString();
      print('Lỗi load user data: $e');
      // Không set _user = null để tránh đăng xuất user
    }
    notifyListeners();
  }

  // Đăng ký tài khoản mới
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('Bắt đầu đăng ký user: $email');

    try {
      _user = await _authService.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      
      _isLoading = false;
      print('Đăng ký thành công: ${_user?['email']}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      print('Lỗi đăng ký: $e');
      print('Error message: $_error');
      notifyListeners();
      return false;
    }
  }

  // Đăng nhập
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
      print('Đăng nhập thành công: ${_user?['email']}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      print('Lỗi đăng nhập: $e');
      notifyListeners();
      return false;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _error = null;
      print('Đăng xuất thành công');
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Lỗi đăng xuất: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Gửi email reset mật khẩu
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      print('Đã gửi email reset password');
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      print('Lỗi reset password: $e');
      notifyListeners();
      return false;
    }
  }

  // Xóa lỗi hiện tại
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Chuyển lỗi từ Firebase sang tiếng Việt dễ hiểu
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