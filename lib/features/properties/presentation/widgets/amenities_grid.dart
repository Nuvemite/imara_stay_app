import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';

/// Amenities Grid Widget
/// Displays property amenities in a grid layout
class AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;

  const AmenitiesGrid({
    super.key,
    required this.amenities,
  });

  // Icon mapping for common amenities
  static IconData _getIconForAmenity(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('internet')) {
      return Icons.wifi;
    } else if (lower.contains('pool')) {
      return Icons.pool;
    } else if (lower.contains('gym') || lower.contains('fitness')) {
      return Icons.fitness_center;
    } else if (lower.contains('parking')) {
      return Icons.local_parking;
    } else if (lower.contains('kitchen')) {
      return Icons.kitchen;
    } else if (lower.contains('tv')) {
      return Icons.tv;
    } else if (lower.contains('ac') || lower.contains('air')) {
      return Icons.ac_unit;
    } else if (lower.contains('washing')) {
      return Icons.local_laundry_service;
    } else if (lower.contains('breakfast')) {
      return Icons.restaurant;
    } else if (lower.contains('security')) {
      return Icons.security;
    } else {
      return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(
                _getIconForAmenity(amenity),
                color: AppTheme.primaryRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  amenity,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
