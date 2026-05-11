import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/core/widgets/imara_stay_logo.dart';
import 'package:imara_stay/features/onboarding/models/onboarding_state.dart';
import 'package:imara_stay/features/onboarding/state/onboarding_controller.dart';
import 'package:imara_stay/features/onboarding/presentation/widgets/role_selection_card.dart';
import 'package:imara_stay/features/auth/presentation/screens/login_screen.dart';
import 'package:imara_stay/features/auth/presentation/screens/registration_screen.dart';

/// RoleSelectionScreen - Critical decision point
/// User chooses Host or Guest, which affects their entire journey
///
/// This is a separate screen (not part of carousel) because:
/// 1. It's a major decision that deserves focus
/// 2. We don't want users accidentally swiping past it
/// 3. We can add more onboarding steps later without cluttering carousel
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state for rebuilds when role changes
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Center(
                child: ImaraStayLogo(
                  size: ImaraStayLogoSize.medium,
                  showIcon: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Header
              Text(
                'Join as a Host or Guest',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                'Choose how you want to use Kenya BnB. You can always change this later.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.greyText),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Role cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Host card
                      RoleSelectionCard(
                        role: UserRole.host,
                        isSelected: state.selectedRole == UserRole.host,
                        onTap: () {
                          controller.selectRole(UserRole.host);
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Guest card
                      RoleSelectionCard(
                        role: UserRole.guest,
                        isSelected: state.selectedRole == UserRole.guest,
                        onTap: () {
                          controller.selectRole(UserRole.guest);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Continue button
              ElevatedButton(
                onPressed: state.hasSelectedRole
                    ? () => _handleContinue(context, ref, controller)
                    : null, // Disabled if no role selected
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.white,
                          ),
                        ),
                      )
                    : const Text('Continue'),
              ),

              // Login Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue(
    BuildContext context,
    WidgetRef ref,
    OnboardingController controller,
  ) async {
    // Save selection
    await controller.completeOnboarding();

    if (context.mounted) {
      final role = ref.read(onboardingProvider).selectedRole;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RegistrationScreen(initialRole: role),
        ),
      );
    }
  }
}
