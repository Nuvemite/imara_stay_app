import 'user_model.dart';

/// AuthStatus - Represents the current stage of the auth lifecycle
enum AuthStatus {
  authenticated,
  unauthenticated,
  authenticating,
  unverified, // Received ID but waiting for OTP
}

/// AuthState - The shape of truth for our authentication system
/// Immutable state for Riverpod
class AuthState {
  final AuthUser? user;
  final AuthStatus status;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.user,
    this.status = AuthStatus.unauthenticated,
    this.error,
    this.isLoading = false,
  });

  /// Standard copyWith pattern for immutability
  AuthState copyWith({
    AuthUser? user,
    AuthStatus? status,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      error: error, // Clear error on update if not provided
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}
