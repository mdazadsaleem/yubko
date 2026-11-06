/// The user object returned by the GharMarkaz Auth API
/// (see the developer's API documentation, 2026-11-06).
class ApiUser {
  const ApiUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.whatsapp,
    this.city,
    this.bio,
    this.isEmailVerified = false,
    this.isVerified = false,
    this.hasPassword = true,
    this.authProvider = 'local',
    this.role = 'user',
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? whatsapp;
  final String? city;
  final String? bio;
  final bool isEmailVerified;
  final bool isVerified;
  final bool hasPassword;
  final String authProvider; // local / google / facebook
  final String role;
  final String? avatarUrl;
  final String? createdAt;

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      city: json['city']?.toString(),
      bio: json['bio']?.toString(),
      isEmailVerified: json['isEmailVerified'] == true,
      isVerified: json['isVerified'] == true,
      hasPassword: json['hasPassword'] != false,
      authProvider: json['authProvider']?.toString() ?? 'local',
      role: json['role']?.toString() ?? 'user',
      avatarUrl: json['avatarUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'whatsapp': whatsapp,
    'city': city,
    'bio': bio,
    'isEmailVerified': isEmailVerified,
    'isVerified': isVerified,
    'hasPassword': hasPassword,
    'authProvider': authProvider,
    'role': role,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt,
  };

  ApiUser copyWith({String? avatarUrl, String? fullName}) {
    return ApiUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone,
      whatsapp: whatsapp,
      city: city,
      bio: bio,
      isEmailVerified: isEmailVerified,
      isVerified: isVerified,
      hasPassword: hasPassword,
      authProvider: authProvider,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }

  String get initial =>
      fullName.trim().isEmpty ? 'G' : fullName.trim()[0].toUpperCase();
}
