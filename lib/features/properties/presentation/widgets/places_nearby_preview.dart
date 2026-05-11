import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';

/// Places Nearby Preview Widget
/// Shows a preview of nearby places on property details screen
class PlacesNearbyPreview extends StatelessWidget {
  final String propertyId;
  final double latitude;
  final double longitude;
  final VoidCallback onViewAll;

  const PlacesNearbyPreview({
    super.key,
    required this.propertyId,
    required this.latitude,
    required this.longitude,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data - will be from API
    final nearbyPlaces = [
      {'name': 'Westgate Mall', 'type': 'Shopping', 'distance': '0.5 km'},
      {'name': 'Java House', 'type': 'Restaurant', 'distance': '0.3 km'},
      {'name': 'Shell Petrol Station', 'type': 'Gas Station', 'distance': '0.2 km'},
      {'name': 'Nakumatt', 'type': 'Supermarket', 'distance': '0.4 km'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Places Nearby',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 20),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'View all',
                style: TextStyle(color: AppTheme.primaryRed),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Places List
        ...nearbyPlaces.take(3).map((place) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildPlaceCard(
                context: context,
                name: place['name'] ?? 'Unknown',
                type: place['type'] ?? 'Place',
                distance: place['distance'] ?? '0 km',
              ),
            )),
      ],
    );
  }

  Widget _buildPlaceCard({
    required BuildContext context,
    required String name,
    required String type,
    required String distance,
  }) {
    IconData icon;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'restaurant':
        icon = Icons.restaurant;
        iconColor = AppTheme.primaryRed;
        break;
      case 'shopping':
        icon = Icons.shopping_bag;
        iconColor = AppTheme.accentOrange;
        break;
      case 'gas station':
        icon = Icons.local_gas_station;
        iconColor = AppTheme.secondaryGreen;
        break;
      case 'supermarket':
        icon = Icons.store;
        iconColor = AppTheme.primaryRed;
        break;
      default:
        icon = Icons.place;
        iconColor = AppTheme.greyText;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGrey),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  type,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            distance,
            style: const TextStyle(
              color: AppTheme.primaryRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
