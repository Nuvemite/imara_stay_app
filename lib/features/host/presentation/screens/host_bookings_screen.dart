import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/core/widgets/imara_stay_logo.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/host/presentation/screens/host_booking_detail_screen.dart';
import 'package:imara_stay/features/host/presentation/widgets/host_booking_card.dart';
import 'package:imara_stay/features/host/state/host_bookings_controller.dart';

/// Host Bookings - list with status filters, approve/reject/cancel actions
class HostBookingsScreen extends ConsumerWidget {
  const HostBookingsScreen({super.key});

  static const List<({String key, String label})> _statusFilters = [
    (key: 'all', label: 'All'),
    (key: 'pending', label: 'Pending'),
    (key: 'upcoming', label: 'Upcoming'),
    (key: 'past', label: 'Past'),
    (key: 'canceled', label: 'Canceled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hostBookingsProvider);
    final controller = ref.read(hostBookingsProvider.notifier);

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
            icon: const Icon(Icons.logout, color: AppTheme.greyText),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                SingleChildScrollView(
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
                const SizedBox(height: AppSpacing.sm),
                _DateRangeFilter(
                  dateFrom: state.dateFrom,
                  dateTo: state.dateTo,
                  onApply: (from, to) => controller.setDateRange(from, to),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: state.isLoading && state.bookings.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryRed),
                  )
                : state.error != null
                    ? _buildError(context, state.error!, controller)
                    : state.bookings.isEmpty
                        ? _buildEmpty(context)
                        : RefreshIndicator(
                            onRefresh: () => controller.loadBookings(page: 1),
                            color: AppTheme.primaryRed,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              itemCount: state.bookings.length +
                                  (state.pagination != null &&
                                          state.pagination!.currentPage <
                                              state.pagination!.lastPage
                                      ? 1
                                      : 0),
                              itemBuilder: (context, i) {
                                if (i >= state.bookings.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: TextButton(
                                        onPressed: () => controller.loadBookings(
                                          page: (state.pagination?.currentPage ?? 1) + 1,
                                        ),
                                        child: const Text('Load more'),
                                      ),
                                    ),
                                  );
                                }
                                final booking = state.bookings[i];
                                return HostBookingCard(
                                  booking: booking,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HostBookingDetailScreen(
                                                bookingId: booking.id),
                                      ),
                                    );
                                  },
                                  onApprove: booking.canApprove
                                      ? () => _confirmAction(
                                            context,
                                            'Approve',
                                            'Approve this booking request?',
                                            () => controller.approveBooking(booking.id),
                                          )
                                      : null,
                                  onReject: booking.canReject
                                      ? () => _confirmAction(
                                            context,
                                            'Reject',
                                            'Reject this booking request?',
                                            () => controller.rejectBooking(booking.id),
                                          )
                                      : null,
                                  onCancel: booking.canCancel
                                      ? () => _confirmAction(
                                            context,
                                            'Cancel',
                                            'Cancel this booking?',
                                            () => controller.cancelBooking(booking.id),
                                          )
                                      : null,
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
    HostBookingsController controller,
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
              onPressed: () => controller.loadBookings(page: 1),
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
              Icons.calendar_today,
              size: 80,
              color: AppTheme.greyText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No bookings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bookings for your listings will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.greyText,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    String title,
    String message,
    Future<bool> Function() action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ok = await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? '$title successful' : 'Failed to $title'),
            backgroundColor: ok ? AppTheme.secondaryGreen : Colors.red.shade700,
          ),
        );
      }
    }
  }
}

class _DateRangeFilter extends StatelessWidget {
  const _DateRangeFilter({
    this.dateFrom,
    this.dateTo,
    required this.onApply,
  });

  final String? dateFrom;
  final String? dateTo;
  final void Function(String? from, String? to) onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dateFrom != null
                    ? DateTime.tryParse(dateFrom!) ?? DateTime.now()
                    : DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null && context.mounted) {
                onApply(date.toIso8601String().split('T').first, dateTo);
              }
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(dateFrom ?? 'From'),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dateTo != null
                    ? DateTime.tryParse(dateTo!) ?? DateTime.now()
                    : DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null && context.mounted) {
                onApply(dateFrom, date.toIso8601String().split('T').first);
              }
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(dateTo ?? 'To'),
          ),
        ),
        TextButton(
          onPressed: dateFrom != null || dateTo != null
              ? () => onApply(null, null)
              : null,
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
