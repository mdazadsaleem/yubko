import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../data/api_user.dart';

/// GetX controller for the signed-in session (Auth API).
///
/// Holds the current user as an observable ([user]) so any screen
/// rebuilds automatically when the session changes, and keeps the
/// JWT token in the platform secure storage, as the developer's
/// API documentation recommends.
class SessionController extends GetxController {
  static SessionController get to => Get.find<SessionController>();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _storage = FlutterSecureStorage();

  /// The signed-in user, or null for guests. Observe with Obx.
  final Rxn<ApiUser> user = Rxn<ApiUser>();

  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null && user.value != null;

  /// Saves a fresh session after login / OTP verification / social login.
  Future<void> save({required String token, required ApiUser newUser}) async {
    _token = token;
    user.value = newUser;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(newUser.toJson()));
  }

  /// Updates the cached user (profile edit, avatar change).
  Future<void> updateUser(ApiUser newUser) async {
    user.value = newUser;
    await _storage.write(key: _userKey, value: jsonEncode(newUser.toJson()));
  }

  /// Restores a saved session at app start. Returns true when a
  /// token was found; the caller verifies it with AuthService.me().
  Future<bool> restore() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      final raw = await _storage.read(key: _userKey);
      if (_token != null && raw != null) {
        user.value = ApiUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        return true;
      }
    } catch (_) {
      // Corrupt storage — start as guest.
    }
    _token = null;
    user.value = null;
    return false;
  }

  /// Clears the session (logout, or a 401 from the API).
  Future<void> clear() async {
    _token = null;
    user.value = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
