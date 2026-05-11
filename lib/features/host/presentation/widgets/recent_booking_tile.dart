import 'package:flutter/material.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_dashboard_model.dart';

/// Tile for recent booking in host dashboard
class RecentBookingTile extends StatelessWidget {
  const RecentBookingTile({
    super.key,
    required this.booking,
    this.onTap,
  });

  final RecentBooking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.guestName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.propertyName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyText,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.checkIn} – ${booking.checkOut}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.greyText,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _statusColor(booking.status),
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.amount,
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
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade700;
      case 'confirmed':
      case 'upcoming':
        return Colors.blue.shade700;
      case 'in-stay':
        return Colors.purple.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'pending':
        return Colors.amber.shade700;
      default:
        return AppTheme.greyText;
    }
  }
}
