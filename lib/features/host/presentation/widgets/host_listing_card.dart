import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_listing_model.dart';

/// Card for host listing in My Listings grid
class HostListingCard extends StatelessWidget {
  const HostListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onMenuTap,
  });

  final HostListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  String get _imageUrl {
    final url = listing.imageUrl;
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final origin = Uri.parse(ApiConfig.baseUrl).origin;
    return origin + (url.startsWith('/') ? url : '/$url');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green.shade700;
      case 'draft':
        return AppTheme.greyText;
      case 'pending':
        return Colors.amber.shade700;
      case 'archived':
        return Colors.red.shade700;
      default:
        return AppTheme.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.lightGrey,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.lightGrey,
                            child: const Icon(
                              Icons.home,
                              size: 48,
                              color: AppTheme.greyText,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.lightGrey,
                          child: const Icon(
                            Icons.home,
                            size: 48,
                            color: AppTheme.greyText,
                          ),
                        ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onMenuTap != null)
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onPressed: onMenuTap,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.greyText,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(listing.status)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            listing.status,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(listing.status),
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          listing.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const Spacer(),
                        Text(
                          'KES ${listing.pricePerNight.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
