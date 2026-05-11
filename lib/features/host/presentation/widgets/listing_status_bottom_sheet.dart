import 'package:flutter/material.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_listing_model.dart';

/// Bottom sheet for changing listing status or deleting
class ListingStatusBottomSheet extends StatelessWidget {
  const ListingStatusBottomSheet({
    super.key,
    required this.listing,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final HostListing listing;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDelete;

  static Future<void> show(
    BuildContext context, {
    required HostListing listing,
    required ValueChanged<String> onStatusChanged,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ListingStatusBottomSheet(
        listing: listing,
        onStatusChanged: onStatusChanged,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = listing.status.toLowerCase();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              listing.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Change status',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.greyText,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (status != 'live')
              _ActionTile(
                label: 'Publish (Live)',
                icon: Icons.public,
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged('live');
                },
              ),
            if (status != 'draft')
              _ActionTile(
                label: 'Unpublish (Draft)',
                icon: Icons.edit_note,
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged('draft');
                },
              ),
            if (status != 'archived')
              _ActionTile(
                label: 'Archive',
                icon: Icons.archive_outlined,
                onTap: () {
                  Navigator.pop(context);
                  onStatusChanged('archived');
                },
              ),
            const Divider(height: AppSpacing.lg),
            _ActionTile(
              label: 'Delete listing',
              icon: Icons.delete_outline,
              iconColor: Colors.red.shade700,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.primaryRed, size: 24),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: iconColor ?? AppTheme.darkText,
        ),
      ),
      onTap: onTap,
    );
  }
}
