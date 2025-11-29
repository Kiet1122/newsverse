import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_preferences.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserPreferences _preferences = UserPreferences();
  bool _isLoading = false;
  String? _error;

  UserPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user preferences from Firestore
  Future<void> loadUserPreferences(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (doc.exists) {
        _preferences = UserPreferences.fromFirestore(doc.data()!);
        if (kDebugMode) {
          print('Preferences loaded: ${_preferences.favoriteCategories}');
        }
      } else {
        // Create default preferences if they don't exist
        await _savePreferencesToFirestore(userId);
      }
    } catch (e) {
      _error = 'Lỗi tải cài đặt: $e';
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update favorite categories
  Future<void> updateFavoriteCategories({
    required String userId,
    required List<String> categories,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _preferences = _preferences.copyWith(favoriteCategories: categories);
      await _savePreferencesToFirestore(userId);
      if (kDebugMode) {
        print('Categories updated: $categories');
      }
    } catch (e) {
      _error = 'Lỗi cập nhật categories: $e';
      if (kDebugMode) {
        print('Error updating categories: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update notifications settings
  Future<void> updateNotifications({
    required String userId,
    required bool enabled,
  }) async {
    try {
      _preferences = _preferences.copyWith(notificationsEnabled: enabled);
      await _savePreferencesToFirestore(userId);
      if (kDebugMode) {
        print('Notifications updated: $enabled');
      }
    } catch (e) {
      _error = 'Lỗi cập nhật thông báo: $e';
      if (kDebugMode) {
        print('Error updating notifications: $e');
      }
      notifyListeners();
    }
  }

  /// Save preferences to Firestore
  Future<void> _savePreferencesToFirestore(String userId) async {
    await _firestore
        .collection('user_preferences')
        .doc(userId)
        .set(_preferences.toJson());
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}