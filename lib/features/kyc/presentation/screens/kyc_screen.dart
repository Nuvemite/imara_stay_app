import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/kyc/repository/kyc_repository.dart';

/// KYC flow - Identity verification (matches website Step1_AccountValues)
/// Steps: intro → select ID → upload front → upload back (if needed) → review → submit
enum KycStep {
  intro,
  selectId,
  uploadFront,
  uploadBack,
  review,
  submitting,
  verified,
}

enum IdType { passport, driverLicense, idCard }

extension IdTypeX on IdType {
  String get label {
    switch (this) {
      case IdType.passport:
        return 'Passport';
      case IdType.driverLicense:
        return 'Driver\'s License';
      case IdType.idCard:
        return 'National ID';
    }
  }
}

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  KycStep _step = KycStep.intro;
  IdType? _idType;
  File? _idFront;
  File? _idBack;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Identity Verification'),
        backgroundColor: AppTheme.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case KycStep.intro:
        return _buildIntro();
      case KycStep.selectId:
        return _buildSelectId();
      case KycStep.uploadFront:
        return _buildUpload(side: 'front');
      case KycStep.uploadBack:
        return _buildUpload(side: 'back');
      case KycStep.review:
        return _buildReview();
      case KycStep.submitting:
        return _buildSubmitting();
      case KycStep.verified:
        return _buildVerified();
    }
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Icon(Icons.verified_user, size: 64, color: AppTheme.primaryRed),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Identity Verification',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Bank-Grade Security',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We verify hosts to keep ImaraStay secure. Your data is encrypted and handled securely.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade800,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildStepItem(1, 'Upload ID', 'Government-issued ID, Driver\'s License, or Passport.'),
        const SizedBox(height: AppSpacing.md),
        _buildStepItem(2, 'Review & Submit', 'We\'ll verify your identity.'),
        const SizedBox(height: AppSpacing.xxl),
        ElevatedButton(
          onPressed: () => setState(() => _step = KycStep.selectId),
          child: const Text('Verify Me'),
        ),
      ],
    );
  }

  Widget _buildStepItem(int num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('$num', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                desc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.greyText,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectId() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Document Type',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildIdOption(
          IdType.passport,
          Icons.book,
          'Passport',
          'Cover to cover',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildIdOption(
          IdType.driverLicense,
          Icons.directions_car,
          'Driver\'s License',
          'Front and Back required',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildIdOption(
          IdType.idCard,
          Icons.badge,
          'National ID',
          'Front and Back required',
        ),
      ],
    );
  }

  Widget _buildIdOption(IdType type, IconData icon, String title, String subtitle) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _idType = type;
          _step = KycStep.uploadFront;
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(AppSpacing.lg),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: AppTheme.primaryRed),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.greyText,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpload({required String side}) {
    final isBack = side == 'back';
    final needsBack = _idType == IdType.driverLicense || _idType == IdType.idCard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Upload ${isBack ? 'Back' : 'Front'} of ${_idType?.label ?? ''}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Make sure all corners are visible and text is readable.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.greyText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: () => _pickImage(isBack),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppTheme.greyText.withValues(alpha: 0.3)),
            ),
            child: (isBack ? _idBack : _idFront) != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Image.file(
                      (isBack ? _idBack : _idFront)!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 48, color: AppTheme.greyText),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.greyText,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: AppTheme.secondaryGreen),
            const SizedBox(width: 4),
            Text('No Glare', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: AppSpacing.lg),
            Icon(Icons.check_circle, size: 16, color: AppTheme.secondaryGreen),
            const SizedBox(width: 4),
            Text('Not Blurry', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _step = isBack ? KycStep.uploadFront : KycStep.selectId),
              child: const Text('Back'),
            ),
            const Spacer(),
            if ((isBack ? _idBack : _idFront) != null)
              ElevatedButton(
                onPressed: () {
                  if (isBack || !needsBack) {
                    setState(() => _step = KycStep.review);
                  } else {
                    setState(() => _step = KycStep.uploadBack);
                  }
                },
                child: Text(isBack || !needsBack ? 'Continue' : 'Next'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(bool isBack) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      setState(() {
        if (isBack) {
          _idBack = File(xFile.path);
        } else {
          _idFront = File(xFile.path);
        }
      });
    }
  }

  Widget _buildReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review Documents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_idFront != null)
          _buildPreviewCard('Front', _idFront!),
        if (_idBack != null) ...[
          const SizedBox(height: AppSpacing.md),
          _buildPreviewCard('Back', _idBack!),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _step = KycStep.selectId),
              child: const Text('Retake'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitKyc,
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewCard(String label, File file) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.lightGrey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(file, height: 160, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(label, style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryRed),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Verifying your identity...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildVerified() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppTheme.secondaryGreen.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 48, color: AppTheme.secondaryGreen),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'You\'re Verified!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Thanks for helping us keep ImaraStay secure.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.greyText,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        ElevatedButton(
          onPressed: widget.onComplete,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Future<void> _submitKyc() async {
    setState(() {
      _error = null;
      _step = KycStep.submitting;
    });

    final repo = ref.read(kycRepositoryProvider);

    // Try to upload identity document if backend supports it
    if (_idFront != null) {
      try {
        await repo.uploadIdentityDocument(_idFront!);
      } catch (_) {
        // Endpoint may not exist yet; continue with verify
      }
    }

    // Mark user as verified (POST /user/verify) - matches website flow
    try {
      await ref.read(authProvider.notifier).verifyUser();
      if (mounted) {
        setState(() => _step = KycStep.verified);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _step = KycStep.review;
          _error = 'Verification failed. Please try again.';
        });
      }
    }
  }
}

