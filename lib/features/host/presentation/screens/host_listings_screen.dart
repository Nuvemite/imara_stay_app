import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/core/widgets/imara_stay_logo.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/host/models/host_listing_model.dart';
import 'package:imara_stay/features/host/presentation/screens/host_listing_detail_screen.dart';
import 'package:imara_stay/features/host/presentation/widgets/host_listing_card.dart';
import 'package:imara_stay/features/host/presentation/widgets/listing_status_bottom_sheet.dart';
import 'package:imara_stay/features/host/state/host_listings_controller.dart';
import 'package:imara_stay/features/listings/presentation/screens/listing_type_selection_screen.dart';

/// Host My Listings - grid with status filters, cards, status/delete actions
class HostListingsScreen extends ConsumerWidget {
  const HostListingsScreen({super.key});

  static const List<({String key, String label})> _statusFilters = [
    (key: 'all', label: 'All'),
    (key: 'live', label: 'Live'),
    (key: 'draft', label: 'Draft'),
    (key: 'pending', label: 'Pending'),
    (key: 'archived', label: 'Archived'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hostListingsProvider);
    final controller = ref.read(hostListingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const ImaraStayLogo(
          size: ImaraStayLogoSize.small,
          showIcon: false,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryRed),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListingTypeSelectionScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.greyText),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter chips
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((f) {
                  final isSelected = state.selectedStatus == f.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(f.label),
                      selected: isSelected,
                      onSelected: (_) => controller.setStatusFilter(f.key),
                      selectedColor: AppTheme.primaryRed.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryRed,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Content
          Expanded(
            child: state.isLoading && state.listings.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryRed),
                  )
                : state.error != null
                    ? _buildError(context, state.error!, controller)
                    : state.listings.isEmpty
                        ? _buildEmpty(context)
                        : RefreshIndicator(
                            onRefresh: () => controller.loadListings(page: 1),
                            color: AppTheme.primaryRed,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                              ),
                              itemCount: state.listings.length +
                                  (state.pagination != null &&
                                          state.pagination!.currentPage <
                                              state.pagination!.lastPage
                                      ? 1
                                      : 0),
                              itemBuilder: (context, i) {
                                if (i >= state.listings.length) {
                                  return _LoadMoreTile(
                                    onTap: () => controller.loadListings(
                                      page: (state.pagination?.currentPage ?? 1) +
                                          1,
                                    ),
                                  );
                                }
                                final listing = state.listings[i];
                                return HostListingCard(
                                  listing: listing,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HostListingDetailScreen(
                                          listing: listing,
                                          controller: controller,
                                        ),
                                      ),
                                    );
                                  },
                                  onMenuTap: () => _showStatusSheet(
                                    context,
                                    listing,
                                    controller,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String error,
    HostListingsController controller,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: AppSpacing.md),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.greyText,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: () => controller.loadListings(page: 1),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 80,
              color: AppTheme.greyText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No listings yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first listing to start hosting.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.greyText,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ListingTypeSelectionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Listing'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(
    BuildContext context,
    HostListing listing,
    HostListingsController controller,
  ) {
    ListingStatusBottomSheet.show(
      context,
      listing: listing,
      onStatusChanged: (status) async {
        final ok = await controller.changeListingStatus(listing.id, status);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ok ? 'Status updated' : 'Failed to update status'),
              backgroundColor: ok ? AppTheme.secondaryGreen : Colors.red.shade700,
            ),
          );
        }
      },
      onDelete: () async {
        final ok = await controller.deleteListing(listing.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ok ? 'Listing deleted' : 'Failed to delete'),
              backgroundColor: ok ? AppTheme.secondaryGreen : Colors.red.shade700,
            ),
          );
        }
      },
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: const Text('Load more'),
      ),
    );
  }
}
