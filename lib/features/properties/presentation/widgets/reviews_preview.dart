import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';

/// Reviews Preview Widget
/// Shows a preview of reviews on property details screen
class ReviewsPreview extends StatelessWidget {
  final String propertyId;
  final double rating;
  final int reviewsCount;
  final VoidCallback onViewAll;

  const ReviewsPreview({
    super.key,
    required this.propertyId,
    required this.rating,
    required this.reviewsCount,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 20),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View all ($reviewsCount)',
                style: const TextStyle(color: AppTheme.primaryRed),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Rating Summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              // Overall Rating
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating.floor()
                            ? Icons.star
                            : index < rating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$reviewsCount reviews',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.greyText),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xl),
              // Rating Breakdown (Mock - will be from API)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRatingBar(context, '5', 0.7),
                    _buildRatingBar(context, '4', 0.2),
                    _buildRatingBar(context, '3', 0.05),
                    _buildRatingBar(context, '2', 0.03),
                    _buildRatingBar(context, '1', 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Sample Review (Mock - will be from API)
        _buildReviewCard(
          context: context,
          name: 'Sarah M.',
          rating: 5,
          date: '2 weeks ago',
          comment:
              'Amazing stay! The apartment was clean, modern, and perfectly located. John was a great host and very responsive.',
        ),
      ],
    );
  }

  Widget _buildRatingBar(BuildContext context, String stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              stars,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppTheme.lightGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String name,
    required int rating,
    required String date,
    required String comment,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGrey),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryRed,
                radius: 20,
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            comment,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
