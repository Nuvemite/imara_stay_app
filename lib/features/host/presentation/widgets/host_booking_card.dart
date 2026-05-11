import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_booking_model.dart';

/// Card for host booking in Bookings list
class HostBookingCard extends StatelessWidget {
  const HostBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.onCancel,
  });

  final HostBooking booking;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  String get _imageUrl {
    final url = booking.listing.imageUrl;
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final origin = Uri.parse(ApiConfig.baseUrl).origin;
    return origin + (url.startsWith('/') ? url : '/$url');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.secondaryGreen;
      case 'pending':
        return Colors.amber.shade700;
      case 'canceled':
        return Colors.red.shade700;
      default:
        return AppTheme.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: SizedBox(
                        width: 80,
                        height: 80,
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
                                    color: AppTheme.greyText,
                                  ),
                                ),
                              )
                            : Container(
                                color: AppTheme.lightGrey,
                                child: const Icon(
                                  Icons.home,
                                  color: AppTheme.greyText,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.listing.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.guest.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.greyText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.checkIn} – ${booking.checkOut}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(booking.status)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.status,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(booking.status),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'KES ${booking.totalPrice.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed,
                              ),
                        ),
                        if (booking.nights > 0)
                          Text(
                            '${booking.nights} night${booking.nights == 1 ? '' : 's'}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppTheme.greyText),
                          ),
                      ],
                    ),
                  ],
                ),
                if (booking.canApprove ||
                    booking.canReject ||
                    booking.canCancel) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (booking.canApprove)
                        TextButton(
                          onPressed: onApprove,
                          child: const Text('Approve'),
                        ),
                      if (booking.canReject)
                        TextButton(
                          onPressed: onReject,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                          ),
                          child: const Text('Reject'),
                        ),
                      if (booking.canCancel)
                        TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                          ),
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
