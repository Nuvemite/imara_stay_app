import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_state.dart';

/// OnboardingController - Think of this as your Redux reducer + thunks combined
/// It extends StateNotifier which is like useState + useReducer in React
/// 
/// StateNotifier<T> means:
/// - It holds state of type T
/// - It can emit new states
/// - Widgets automatically rebuild when state changes
class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState()) {
    // Constructor - starts with initial state
    _loadOnboardingStatus();
  }

  // Keys for persistent storage (SharedPreferences)
  static const String _onboardingKey = 'has_completed_onboarding';
  static const String _roleKey = 'user_role';

  /// Load saved onboarding status from local storage
  /// This runs when the controller initializes
  /// Like checking localStorage in React on mount
  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_onboardingKey) ?? false;
    final roleString = prefs.getString(_roleKey);

    UserRole? role;
    if (roleString != null) {
      // Convert string back to enum
      role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.guest,
      );
    }

    // Update state with loaded data
    state = state.copyWith(
      hasCompletedOnboarding: completed,
      selectedRole: role,
    );
  }

  /// Move to next page in the carousel
  void nextPage() {
    if (state.canProceed) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  /// Move to previous page
  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  /// Jump to specific page
  void goToPage(int page) {
    if (page >= 0 && page <= 2) {
      state = state.copyWith(currentPage: page);
    }
  }

  /// User selects their role (Host or Guest)
  /// This is a critical business decision that affects the entire app
  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  /// Complete onboarding process
  /// This persists the decision and marks onboarding as done
  Future<void> completeOnboarding() async {
    if (!state.hasSelectedRole) {
      // Don't allow completion without role selection
      return;
    }

    // Show loading state
    state = state.copyWith(isLoading: true);

    try {
      // Persist to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      await prefs.setString(_roleKey, state.selectedRole!.name);

      // Simulate a small delay (remove this in production)
      // Just to show the loading state working
      await Future.delayed(const Duration(milliseconds: 500));

      // Mark as completed
      state = state.copyWith(
        hasCompletedOnboarding: true,
        isLoading: false,
      );
    } catch (e) {
      // Error handling - revert loading state
      state = state.copyWith(isLoading: false);
      // In production, you'd show an error message here
      rethrow;
    }
  }

  /// Skip onboarding (optional feature)
  /// Some apps allow skipping - you can remove this if not needed
  Future<void> skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  /// Reset onboarding (useful for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_roleKey);
    state = const OnboardingState();
  }
}

/// Provider - this is how widgets access the controller
/// Think of it like: export const onboardingProvider = ...
/// But type-safe and with automatic cleanup
final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
  (ref) => OnboardingController(),
);