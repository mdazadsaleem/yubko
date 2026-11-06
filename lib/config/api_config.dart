/// API configuration for the GharMarkaz backend.
///
/// From the developer's "Authentication & User API" documentation
/// (received 2026-11-06). All auth endpoints live under [authBaseUrl].
///
/// IMPORTANT: the documentation's "production" URL
/// (api.techsolutionor.com) is wrong — that server answers every
/// auth POST with 404 "Cannot POST /api/auth/...". The real API is
/// the one the yubko.com website itself uses, found in the site's
/// own JS bundle (2026-11-06) and verified endpoint-by-endpoint:
/// its validation messages match the documentation word-for-word.
class ApiConfig {
  ApiConfig._();

  /// Production auth API base URL.
  static const String authBaseUrl = 'https://server.yubko.com/api/auth';

  /// Request timeout for every API call.
  static const Duration timeout = Duration(seconds: 30);
}
