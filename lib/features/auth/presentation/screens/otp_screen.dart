import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/auth/presentation/screens/login_screen.dart';

/// OTP screen - Deprecated in favor of email/password login.
/// Kept for potential future OTP flow.
class OtpVerificationScreen extends StatelessWidget {
  final String identifier;
  final String? name;

  const OtpVerificationScreen({super.key, required this.identifier, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Account')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(
              Icons.info_outline,
              size: 80,
              color: AppTheme.primaryRed,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'OTP verification is not available',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Please use email and password to sign in.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
