import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/places/models/place_model.dart';

/// Place card - displays a single nearby place
class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  IconData _getIconForCategory(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.restaurant:
        return Icons.restaurant;
      case PlaceCategory.bar:
        return Icons.local_bar;
      case PlaceCategory.supermarket:
        return Icons.store;
      case PlaceCategory.gasStation:
        return Icons.local_gas_station;
      case PlaceCategory.park:
        return Icons.park;
      case PlaceCategory.hospital:
        return Icons.local_hospital;
      case PlaceCategory.bank:
        return Icons.account_balance;
      case PlaceCategory.transport:
        return Icons.directions_car;
      case PlaceCategory.shopping:
        return Icons.shopping_bag;
      default:
        return Icons.place;
    }
  }

  Color _getColorForCategory(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.restaurant:
        return AppTheme.primaryRed;
      case PlaceCategory.bar:
        return AppTheme.accentOrange;
      case PlaceCategory.supermarket:
        return AppTheme.primaryRed;
      case PlaceCategory.gasStation:
        return AppTheme.secondaryGreen;
      case PlaceCategory.park:
        return AppTheme.secondaryGreen;
      case PlaceCategory.shopping:
        return AppTheme.accentOrange;
      default:
        return AppTheme.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForCategory(place.category);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _getIconForCategory(place.category),
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (place.rating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                place.rating!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.category.label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.greyText),
                    ),
                    if (place.address != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        place.address!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppTheme.greyText,
                              fontSize: 11,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.distance,
                    style: const TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!place.isOpen)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Closed',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
