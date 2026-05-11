import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:imara_stay/core/api/api_client.dart';
import 'package:imara_stay/features/auth/models/auth_state.dart';
import 'package:imara_stay/features/auth/models/user_model.dart';
import 'package:imara_stay/features/onboarding/models/onboarding_state.dart';

/// AuthController - Manages user authentication and session
/// Uses email/password with Laravel backend
class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthState()) {
    _loadSession();
  }

  static const String _userKey = 'auth_user';
  static const String _tokenKey = 'auth_token';

  /// Load session from SharedPreferences
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);

    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        if (token != null) userData['token'] = token;
        final user = AuthUser.fromJson(userData);
        state = state.copyWith(user: user, status: AuthStatus.authenticated);
      } catch (e) {
        await prefs.remove(_userKey);
        await prefs.remove(_tokenKey);
      }
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = ApiClient();
      final response = await client.post('/login', body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String?;
        final userData = data['user'] as Map<String, dynamic>? ?? {};
        if (token != null) userData['token'] = token;

        final user = AuthUser.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        if (token != null) await prefs.setString(_tokenKey, token);

        state = state.copyWith(
          user: user,
          status: AuthStatus.authenticated,
          isLoading: false,
          error: null,
        );
      } else {
        final body = jsonDecode(response.body);
        final msg = _extractErrorMessage(body, 'Login failed');
        throw Exception(msg);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Register with name, email, password, optional phone and role
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    UserRole role = UserRole.guest,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = ApiClient();
      final response = await client.post('/register', body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'role': role.name,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String?;
        final userData = data['user'] as Map<String, dynamic>? ?? {};
        if (token != null) userData['token'] = token;

        final user = AuthUser.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        if (token != null) await prefs.setString(_tokenKey, token);

        state = state.copyWith(
          user: user,
          status: AuthStatus.authenticated,
          isLoading: false,
          error: null,
        );

        // If host, apply to become host (creates HostProfile)
        if (user.role == UserRole.host) {
          _applyToBecomeHost(token);
        }
      } else {
        final body = jsonDecode(response.body);
        final msg = _extractErrorMessage(body, 'Registration failed');
        throw Exception(msg);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> _applyToBecomeHost(String? token) async {
    if (token == null) return;
    try {
      final client = ApiClient(token: token);
      await client.post('/host/apply');
    } catch (_) {
      // Non-blocking; host can apply later from dashboard
    }
  }

  /// Get stored token for API client (e.g. PropertyController)
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Update profile (name, phone, bio)
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bio,
  }) async {
    final user = state.user;
    if (user == null) return;

    final token = await getStoredToken();
    if (token == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = ApiClient(token: token);
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (bio != null) body['bio'] = bio;

      final response = await client.put('/user', body: body.isNotEmpty ? body : null);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? {};
        userData['token'] = token;
        final updatedUser = AuthUser.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));

        state = state.copyWith(user: updatedUser, isLoading: false, error: null);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(_extractErrorMessage(body, 'Update failed'));
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Upload avatar image
  Future<void> uploadAvatar(File imageFile) async {
    final user = state.user;
    if (user == null) return;

    final token = await getStoredToken();
    if (token == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = ApiClient(token: token);
      final streamedResponse = await client.postMultipart(
        '/user/avatar',
        fieldName: 'avatar',
        file: imageFile,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? {};
        userData['token'] = token;
        final updatedUser = AuthUser.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));

        state = state.copyWith(user: updatedUser, isLoading: false, error: null);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(_extractErrorMessage(body, 'Upload failed'));
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Mark user as verified (after KYC)
  Future<void> verifyUser() async {
    final user = state.user;
    if (user == null) return;

    final token = await getStoredToken();
    if (token == null) return;

    try {
      final client = ApiClient(token: token);
      final response = await client.post('/user/verify');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? {};
        userData['token'] = token;
        final updatedUser = AuthUser.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));

        state = state.copyWith(user: updatedUser);
      }
    } catch (_) {
      rethrow;
    }
  }

  /// Extract error message from Laravel validation response
  static String _extractErrorMessage(dynamic body, String fallback) {
    if (body is! Map) return fallback;
    if (body['message'] != null) return body['message'].toString();
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first?.toString() ?? fallback;
    }
    return fallback;
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    state = const AuthState();
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
