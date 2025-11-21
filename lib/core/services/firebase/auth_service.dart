import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Service xử lý đăng ký, đăng nhập với Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy thông tin user hiện tại
  User? get currentUser => _auth.currentUser;

  // Theo dõi trạng thái đăng nhập (dùng để tự động chuyển trang)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Đăng ký tài khoản mới
  Future<Map<String, dynamic>?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('Bắt đầu đăng ký: $email');
      
      // Tạo tài khoản trong Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Đăng ký Firebase Auth thành công: ${credential.user!.uid}');

      // Tạo dữ liệu user để lưu vào database
      final userData = {
        'name': name,
        'email': email,
        'role': role,
        'avatarUrl': null, // Ảnh đại diện (chưa có)
        'favoriteCategories': [], // Danh mục yêu thích
        'createdAt': Timestamp.fromDate(DateTime.now()), // Ngày tạo
        'updatedAt': Timestamp.fromDate(DateTime.now()), // Ngày cập nhật
        'lastLogin': Timestamp.fromDate(DateTime.now()), // Lần đăng nhập cuối
        'preferences': {}, // Cài đặt cá nhân
      };

      // Lưu thông tin user vào Firestore database
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      print('Tạo user trong Firestore thành công');

      // Trả về thông tin user đã đăng ký
      return {
        'id': credential.user!.uid,
        ...userData,
      };
    } catch (e) {
      print('Lỗi đăng ký: $e');
      throw _handleAuthError(e);
    }
  }

  // Đăng nhập với email và mật khẩu
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Xác thực với Firebase Auth
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật thời gian đăng nhập cuối
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Lấy thông tin user từ database
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': userDoc.id,
        };
      }
      return null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Gửi email reset mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Lấy thông tin user từ database
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': userDoc.id,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin user: $e');
    }
  }

  // Xử lý lỗi từ Firebase - chuyển thành tiếng Việt dễ hiểu
  String _handleAuthError(dynamic error) {
    print('Lỗi Firebase Auth: ${error.toString()}');
    
    if (error is FirebaseAuthException) {
      print('Mã lỗi: ${error.code}');
      print('Thông báo lỗi: ${error.message}');
      
      // Dịch các lỗi phổ biến sang tiếng Việt
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email đã được sử dụng. Vui lòng sử dụng email khác.';
        case 'invalid-email':
          return 'Địa chỉ email không hợp lệ.';
        case 'weak-password':
          return 'Mật khẩu quá yếu. Mật khẩu phải có ít nhất 6 ký tự.';
        case 'user-not-found':
          return 'Không tìm thấy người dùng với email này.';
        case 'wrong-password':
          return 'Mật khẩu không chính xác.';
        case 'user-disabled':
          return 'Tài khoản đã bị vô hiệu hóa.';
        case 'too-many-requests':
          return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
        case 'operation-not-allowed':
          return 'Phương thức đăng ký không được kích hoạt. Liên hệ quản trị viên.';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
        default:
          return 'Đã xảy ra lỗi: ${error.code}. Vui lòng thử lại.';
      }
    }
    return 'Lỗi không xác định: ${error.toString()}';
  }
}