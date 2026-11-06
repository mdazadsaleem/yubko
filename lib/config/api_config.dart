/// API configuration for the GharMarkaz backend.
///
/// From the developer's "Authentication & User API" documentation
/// (received 2026-11-06). All auth endpoints live under [authBaseUrl].
///
/// NOTE: the documentation lists this production URL with the remark
/// "Replace with your live domain" — if the developer hosts the API
/// somewhere else, change this ONE line.
class ApiConfig {
  ApiConfig._();

  /// Production auth API base URL.
  static const String authBaseUrl = 'https://api.techsolutionor.com/api/auth';

  /// Request timeout for every API call.
  static const Duration timeout = Duration(seconds: 30);
}
