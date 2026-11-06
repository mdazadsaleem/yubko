import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/api_user.dart';

/// Holds the signed-in session: the JWT token and the current user.
///
/// The token is kept in the platform secure storage (Keychain /
/// EncryptedSharedPreferences), as the API documentation recommends.
/// [currentUser] is an in-memory notifier so screens can rebuild when
/// the session changes. Guests simply have no session.
class SessionStore {
  SessionStore._();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _storage = FlutterSecureStorage();

  static String? _token;
  static final ValueNotifier<ApiUser?> currentUser = ValueNotifier(null);

  static String? get token => _token;
  static bool get isLoggedIn => _token != null && currentUser.value != null;

  /// Saves a fresh session after login / OTP verification / social login.
  static Future<void> save({
    required String token,
    required ApiUser user,
  }) async {
    _token = token;
    currentUser.value = user;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  /// Updates the cached user (profile edit, avatar change).
  static Future<void> updateUser(ApiUser user) async {
    currentUser.value = user;
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  /// Restores a saved session at app start. Returns true when a token
  /// was found; the caller should verify it with AuthService.me().
  static Future<bool> restore() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      final raw = await _storage.read(key: _userKey);
      if (_token != null && raw != null) {
        currentUser.value = ApiUser.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        return true;
      }
    } catch (_) {
      // Corrupt storage — start as guest.
    }
    _token = null;
    currentUser.value = null;
    return false;
  }

  /// Clears the session (logout, or a 401 from the API).
  static Future<void> clear() async {
    _token = null;
    currentUser.value = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
