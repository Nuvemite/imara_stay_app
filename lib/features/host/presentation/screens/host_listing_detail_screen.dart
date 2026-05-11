import 'package:flutter/material.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_listing_model.dart';
import 'package:imara_stay/features/host/presentation/screens/host_calendar_screen.dart';
import 'package:imara_stay/features/host/presentation/widgets/listing_status_bottom_sheet.dart';
import 'package:imara_stay/features/host/state/host_listings_controller.dart';
import 'package:imara_stay/features/listings/presentation/screens/listing_type_selection_screen.dart';

/// Host listing detail - view, edit, calendar, status, delete
class HostListingDetailScreen extends StatelessWidget {
  const HostListingDetailScreen({
    super.key,
    required this.listing,
    required this.controller,
  });

  final HostListing listing;
  final HostListingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Listing'),
        backgroundColor: AppTheme.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HostCalendarScreen(listingId: listing.id),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ListingTypeSelectionScreen(),
                  ),
                );
              } else if (value == 'status') {
                ListingStatusBottomSheet.show(
                  context,
                  listing: listing,
                  onStatusChanged: (status) async {
                    final ok =
                        await controller.changeListingStatus(listing.id, status);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              ok ? 'Status updated' : 'Failed to update status'),
                          backgroundColor: ok
                              ? AppTheme.secondaryGreen
                              : Colors.red.shade700,
                        ),
                      );
                      if (ok) Navigator.pop(context);
                    }
                  },
                  onDelete: () async {
                    final ok = await controller.deleteListing(listing.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              ok ? 'Listing deleted' : 'Failed to delete'),
                          backgroundColor: ok
                              ? AppTheme.secondaryGreen
                              : Colors.red.shade700,
                        ),
                      );
                      if (ok) Navigator.pop(context);
                    }
                  },
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit listing')),
              const PopupMenuItem(value: 'status', child: Text('Change status')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.location,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.greyText,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _badge(context, listing.status),
                      const SizedBox(width: 8),
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(listing.rating.toStringAsFixed(1)),
                      const Spacer(),
                      Text(
                        'KES ${listing.pricePerNight.toStringAsFixed(0)}/night',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRed,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${listing.bedrooms} bedrooms · ${listing.beds} beds · ${listing.bathrooms} baths',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyText,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    HostCalendarScreen(listingId: listing.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Calendar'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ListingTypeSelectionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
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
    );
  }

  Widget _badge(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'live':
        color = Colors.green.shade700;
        break;
      case 'draft':
        color = AppTheme.greyText;
        break;
      case 'pending':
        color = Colors.amber.shade700;
        break;
      case 'archived':
        color = Colors.red.shade700;
        break;
      default:
        color = AppTheme.greyText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
