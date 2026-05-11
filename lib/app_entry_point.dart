import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/features/auth/models/auth_state.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:imara_stay/features/onboarding/models/onboarding_state.dart';
import 'package:imara_stay/features/onboarding/presentation/onboarding_screen.dart';
import 'package:imara_stay/features/onboarding/state/onboarding_controller.dart';
import 'package:imara_stay/features/properties/presentation/screens/guest_shell_screen.dart';
import 'package:imara_stay/features/host/presentation/screens/host_shell_screen.dart';

/// AppEntryPoint - Routes based on auth and onboarding status
/// - First time: Onboarding
/// - Default (Guest or Unauthenticated): GuestShellScreen (Explore | Wishlists | Profile)
/// - Authenticated Host (Verified): HostShellScreen (Dashboard | Listings | Bookings | Profile)
/// - Authenticated Host (Unverified): KycScreen
class AppEntryPoint extends ConsumerWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final onboardingState = ref.watch(onboardingProvider);

    // If first open, show onboarding
    if (!onboardingState.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // Authenticated - route by role
    if (authState.status == AuthStatus.authenticated) {
      final role = authState.user?.role ?? UserRole.guest;
      final isVerified = authState.user?.isVerified ?? false;

      if (role == UserRole.host) {
        // Hosts must complete KYC before accessing dashboard
        if (!isVerified) {
          return KycScreen(
            onComplete: () => ref.invalidate(authProvider),
          );
        }
        return const HostShellScreen();
      }
    }

    // Default: Return Guest Interface for unauthenticated or 'Guest' users
    return const GuestShellScreen();
  }
}
