import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/core/widgets/imara_stay_logo.dart';
import 'package:imara_stay/features/listings/models/listing_type.dart';
import 'package:imara_stay/features/listings/presentation/screens/listing_wizard_screen.dart';

/// Screen to choose what type of listing to create (Home, Experience, Service)
class ListingTypeSelectionScreen extends StatelessWidget {
  const ListingTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ImaraStayLogo(size: ImaraStayLogoSize.small, showIcon: false),
        centerTitle: true,
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
              Text(
                'What would you like to list?',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose the type of listing you want to create.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.greyText,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ...ListingType.values.map((type) => _TypeCard(
                    type: type,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ListingWizardScreen(
                            initialType: type,
                          ),
                        ),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.onTap});

  final ListingType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(type.icon, size: 32, color: AppTheme.primaryRed),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.greyText,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.greyText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
