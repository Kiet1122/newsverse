import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Service for handling authentication with Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user information
  User? get currentUser => _auth.currentUser;

  // Stream to monitor authentication state changes (for automatic page navigation)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user account with email and password
  Future<Map<String, dynamic>?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print('Starting registration: $email');
      
      // Create account in Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Auth registration successful: ${credential.user!.uid}');

      // Create user data to save in database
      final userData = {
        'name': name,
        'email': email,
        'role': role,
        'avatarUrl': null, // Profile picture (not available yet)
        'favoriteCategories': [], // Favorite categories
        'createdAt': Timestamp.fromDate(DateTime.now()), // Creation date
        'updatedAt': Timestamp.fromDate(DateTime.now()), // Update date
        'lastLogin': Timestamp.fromDate(DateTime.now()), // Last login
        'preferences': {}, // Personal settings
      };

      // Save user information to Firestore database
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      print('User created successfully in Firestore');

      // Return registered user information
      return {
        'id': credential.user!.uid,
        ...userData,
      };
    } catch (e) {
      print('Registration error: $e');
      throw _handleAuthError(e);
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Authenticate with Firebase Auth
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Get user information from database
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

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Get user data from database
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

  /// Handle Firebase authentication errors and convert to Vietnamese messages
  String _handleAuthError(dynamic error) {
    print('Firebase Auth error: ${error.toString()}');
    
    if (error is FirebaseAuthException) {
      print('Error code: ${error.code}');
      print('Error message: ${error.message}');
      
      // Translate common errors to Vietnamese
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