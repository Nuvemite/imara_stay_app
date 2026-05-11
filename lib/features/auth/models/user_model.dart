import 'package:imara_stay/features/onboarding/models/onboarding_state.dart';

/// AuthUser - Represents a user in the system
/// Contains identity, role, and token for API calls
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? bio;
  final UserRole role;
  final String? token;
  final bool isVerified;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.bio,
    required this.role,
    this.token,
    this.isVerified = false,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'role': role.name,
      'token': token,
      'is_verified': isVerified,
    };
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    UserRole? role,
    String? token,
    bool? isVerified,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      token: token ?? this.token,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Create from Laravel API response (user object)
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    dynamic roleStr = json['role'];
    if (roleStr == null && json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      final first = (json['roles'] as List).first;
      roleStr = first is Map ? first['name'] : null;
    }
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      bio: json['bio']?.toString(),
      role: UserRole.values.firstWhere(
        (r) => r.name == roleStr?.toString().toLowerCase(),
        orElse: () => UserRole.guest,
      ),
      token: json['token'] as String?,
      isVerified: json['is_verified'] == true,
    );
  }

  @override
  String toString() => 'AuthUser(id: $id, name: $name, role: ${role.label})';
}
