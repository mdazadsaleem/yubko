import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/api_user.dart';
import 'session_store.dart';

/// An error returned by the API (or a network failure).
/// [message] is the server's own message, safe to show to the user.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.data});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  /// Login with an unverified email: the server sent a fresh OTP and
  /// the app must open the OTP screen (HTTP 403, requiresOtp: true).
  bool get requiresOtp => data?['requiresOtp'] == true;

  /// Account suspended by administration (HTTP 403, isSuspended: true).
  bool get isSuspended => data?['isSuspended'] == true;

  @override
  String toString() => message;
}

/// Result of endpoints that log the user in.
class AuthSession {
  const AuthSession({required this.token, required this.user, this.message});
  final String token;
  final ApiUser user;
  final String? message;
}

/// Client for the GharMarkaz Authentication & User API — all 14
/// endpoints from the developer's documentation (2026-11-06):
/// register, verify-otp, resend-otp, login, me, forgot-password,
/// verify-reset-otp, reset-password, change-password, google,
/// facebook, update profile, upload avatar, remove avatar.
class AuthService {
  AuthService._();

  static Uri _uri(String path) => Uri.parse('${ApiConfig.authBaseUrl}$path');

  static Map<String, String> _headers({bool auth = false}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (auth && SessionStore.token != null)
      'Authorization': 'Bearer ${SessionStore.token}',
  };

  static Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {
      // Non-JSON response (e.g. a proxy error page).
    }
    if (response.statusCode == 401 && SessionStore.isLoggedIn) {
      // Token expired/invalid — the docs say: log the user out.
      SessionStore.clear();
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message']?.toString() ??
          (response.statusCode == 500
              ? 'Server error, please try again later'
              : 'Request failed (${response.statusCode}).'),
      statusCode: response.statusCode,
      data: body,
    );
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> json, {
    bool auth = false,
  }) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: _headers(auth: auth),
            body: jsonEncode(json),
          )
          .timeout(ApiConfig.timeout);
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    }
  }

  static Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> json,
  ) async {
    try {
      final response = await http
          .put(
            _uri(path),
            headers: _headers(auth: true),
            body: jsonEncode(json),
          )
          .timeout(ApiConfig.timeout);
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    }
  }

  static AuthSession _sessionFrom(Map<String, dynamic> body) {
    return AuthSession(
      token: body['token']?.toString() ?? '',
      user: ApiUser.fromJson(body['user'] as Map<String, dynamic>? ?? {}),
      message: body['message']?.toString(),
    );
  }

  // 1) POST /register — creates a pending account, emails a 6-digit OTP.
  static Future<String> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? whatsapp,
    String? city,
    String? bio,
  }) async {
    final body = await _post('/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      if (whatsapp != null && whatsapp.isNotEmpty) 'whatsapp': whatsapp,
      if (city != null && city.isNotEmpty) 'city': city,
      if (bio != null && bio.isNotEmpty) 'bio': bio,
    });
    return body['email']?.toString() ?? email;
  }

  // 2) POST /verify-otp — activates the account and logs in.
  static Future<AuthSession> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final body = await _post('/verify-otp', {
      'email': email,
      'otpCode': otpCode,
    });
    return _sessionFrom(body);
  }

  // 3) POST /resend-otp — sends a new registration OTP.
  static Future<void> resendOtp({required String email}) async {
    await _post('/resend-otp', {'email': email});
  }

  // 4) POST /login — email + password. Throws ApiException with
  //    requiresOtp on 403 for unverified emails.
  static Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final body = await _post('/login', {'email': email, 'password': password});
    return _sessionFrom(body);
  }

  // 5) GET /me — the current user's profile (token check on start).
  static Future<ApiUser> me() async {
    try {
      final response = await http
          .get(_uri('/me'), headers: _headers(auth: true))
          .timeout(ApiConfig.timeout);
      final body = _decode(response);
      return ApiUser.fromJson(body['user'] as Map<String, dynamic>? ?? {});
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    }
  }

  // 6) POST /forgot-password — emails a password-reset OTP.
  static Future<void> forgotPassword({required String email}) async {
    await _post('/forgot-password', {'email': email});
  }

  // 7) POST /verify-reset-otp — returns a 15-minute resetToken.
  static Future<String> verifyResetOtp({
    required String email,
    required String otpCode,
  }) async {
    final body = await _post('/verify-reset-otp', {
      'email': email,
      'otpCode': otpCode,
    });
    return body['resetToken']?.toString() ?? '';
  }

  // 8) POST /reset-password — sets the new password via resetToken.
  static Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final body = await _post('/reset-password', {
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
    return body['message']?.toString() ?? 'Password updated successfully!';
  }

  // 9) PUT /change-password — logged-in password change.
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _put('/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // 10) POST /google — exchanges a Google ID token for a session.
  static Future<AuthSession> loginWithGoogle(String idToken) async {
    final body = await _post('/google', {'idToken': idToken});
    return _sessionFrom(body);
  }

  // 11) POST /facebook — exchanges a Facebook access token.
  //     (Needs the Facebook SDK + App ID from the developer before
  //     the app can obtain an access token; see the report.)
  static Future<AuthSession> loginWithFacebook(String accessToken) async {
    final body = await _post('/facebook', {'accessToken': accessToken});
    return _sessionFrom(body);
  }

  // 12) PUT /profile — updates profile fields.
  static Future<ApiUser> updateProfile({
    String? fullName,
    String? phone,
    String? whatsapp,
    String? city,
    String? bio,
  }) async {
    final body = await _put('/profile', {
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (city != null) 'city': city,
      if (bio != null) 'bio': bio,
    });
    return ApiUser.fromJson(body['user'] as Map<String, dynamic>? ?? {});
  }

  // 13) POST /profile/avatar — multipart upload, form key "avatar".
  static Future<ApiUser> uploadAvatar(File file) async {
    try {
      final request = http.MultipartRequest('POST', _uri('/profile/avatar'));
      if (SessionStore.token != null) {
        request.headers['Authorization'] = 'Bearer ${SessionStore.token}';
      }
      request.files.add(await http.MultipartFile.fromPath('avatar', file.path));
      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);
      final body = _decode(response);
      if (body['user'] is Map<String, dynamic>) {
        return ApiUser.fromJson(body['user'] as Map<String, dynamic>);
      }
      final current = SessionStore.currentUser.value;
      return current!.copyWith(avatarUrl: body['avatarUrl']?.toString());
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    }
  }

  // 14) DELETE /profile/avatar — removes the profile photo.
  static Future<ApiUser> removeAvatar() async {
    try {
      final response = await http
          .delete(_uri('/profile/avatar'), headers: _headers(auth: true))
          .timeout(ApiConfig.timeout);
      final body = _decode(response);
      return ApiUser.fromJson(body['user'] as Map<String, dynamic>? ?? {});
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection.',
      );
    }
  }
}
