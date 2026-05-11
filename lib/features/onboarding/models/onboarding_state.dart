enum UserRole {
  host('Host', 'List your property and earn'),
  guest('Guest', 'Find your perfect stay');

  final String label;
  final String description;
  const UserRole(this.label, this.description);
}

/// Onboarding state model
/// This is immutable - every change creates a new instance
/// (Like Redux, but enforced by the language)
class OnboardingState {
  final int currentPage;
  final bool hasCompletedOnboarding;
  final UserRole? selectedRole;
  final bool isLoading;

  const OnboardingState({
    this.currentPage = 0,
    this.hasCompletedOnboarding = false,
    this.selectedRole,
    this.isLoading = false,
  });

  /// copyWith pattern - this is how you "update" immutable objects
  /// In React/Redux, you'd do { ...state, currentPage: 1 }
  /// In Dart, we do state.copyWith(currentPage: 1)
  OnboardingState copyWith({
    int? currentPage,
    bool? hasCompletedOnboarding,
    UserRole? selectedRole,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Helper getters for UI logic
  bool get hasSelectedRole => selectedRole != null;
  bool get canProceed => currentPage < 2; // 3 pages total (0, 1, 2)
  bool get isLastPage => currentPage == 2;

  @override
  String toString() {
    return 'OnboardingState(page: $currentPage, completed: $hasCompletedOnboarding, role: $selectedRole)';
  }
}
