import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/properties/presentation/screens/property_details_screen.dart';
import 'package:imara_stay/features/properties/presentation/widgets/property_card.dart';
import 'package:imara_stay/features/properties/state/property_controller.dart';
import 'package:imara_stay/features/saved/state/favourites_controller.dart';

/// Favourites Screen - Shows favourited properties
class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouriteIds = ref.watch(favouritesProvider);
    final propertyState = ref.watch(propertyProvider);
    final favouritesController = ref.read(favouritesProvider.notifier);

    final properties = propertyState.properties
        .where((p) => favouriteIds.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Favourites',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.darkText,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: properties.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(favouritesProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];

                  return PropertyCard(
                    property: property,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsScreen(
                            propertyId: property.id,
                          ),
                        ),
                      );
                    },
                    isFavourite: true,
                    onFavouriteTap: () =>
                        favouritesController.toggle(property.id),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppTheme.greyText.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No favourites yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tap the heart icon on any property to add it here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.greyText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
