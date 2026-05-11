import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/onboarding/models/onboarding_content.dart';

/// OnboardingPageWidget - Displays a single onboarding slide
/// This is presentation-only, no logic
///
/// Compare to React:
/// const OnboardingPageWidget = ({ page }) => {
///   return <View>...</View>
/// }
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: page.backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Image
              // In production, replace with Lottie animation or image
              Icon(page.icon, size: 120, color: AppTheme.white),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.white,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              Text(
                page.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.white,
                  fontSize: 16,
                  height: 1.5, // Line height for readability
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
