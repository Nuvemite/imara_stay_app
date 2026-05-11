import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/onboarding/models/onboarding_state.dart';

/// RoleSelectionCard - A selectable card for choosing user role
/// This shows how to build interactive components that look good
///
/// Like a fancy <TouchableOpacity> in React Native, but with more style
class RoleSelectionCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed : AppTheme.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : AppTheme.lightGrey,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              _getIconForRole(role),
              size: 64,
              color: isSelected ? AppTheme.white : AppTheme.primaryRed,
            ),

            const SizedBox(height: AppSpacing.md),

            // Role label
            Text(
              role.label,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: isSelected ? AppTheme.white : AppTheme.darkText,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              role.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? AppTheme.white.withOpacity(0.9)
                    : AppTheme.greyText,
              ),
            ),

            // Checkmark indicator when selected
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.primaryRed,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.host:
        return Icons.home_work_rounded;
      case UserRole.guest:
        return Icons.luggage_rounded;
    }
  }
}
