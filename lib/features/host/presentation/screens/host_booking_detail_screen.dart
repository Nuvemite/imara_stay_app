import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_booking_model.dart';
import 'package:imara_stay/features/host/state/host_bookings_controller.dart';

/// Host booking detail - guest, dates, status, amount, approve/reject/cancel
class HostBookingDetailScreen extends ConsumerStatefulWidget {
  const HostBookingDetailScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  ConsumerState<HostBookingDetailScreen> createState() =>
      _HostBookingDetailScreenState();
}

class _HostBookingDetailScreenState extends ConsumerState<HostBookingDetailScreen> {
  HostBooking? _booking;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final controller = ref.read(hostBookingsProvider.notifier);
    final b = await controller.loadBookingDetail(widget.bookingId);
    if (mounted) {
      setState(() {
        _booking = b;
        _loading = false;
        _error = b == null ? 'Failed to load booking' : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Detail')),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    if (_error != null || _booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Detail')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Not found'),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final b = _booking!;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Booking Detail'),
        backgroundColor: AppTheme.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.listing.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.listing.location,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.greyText,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRow('Guest', b.guest.name),
                  _buildRow('Check-in', b.checkIn),
                  _buildRow('Check-out', b.checkOut),
                  _buildRow('Nights', '${b.nights}'),
                  _buildRow('Guests', '${b.guests.total} (${b.guests.adults} adults, ${b.guests.children} children)'),
                  _buildRow('Status', b.status),
                  _buildRow('Amount', 'KES ${b.totalPrice.toStringAsFixed(0)}'),
                  if (b.confirmationCode != null)
                    _buildRow('Confirmation', b.confirmationCode!),
                ],
              ),
            ),
            if (b.canApprove || b.canReject || b.canCancel) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (b.canApprove)
                      ElevatedButton(
                        onPressed: () => _action('approve', b.id),
                        child: const Text('Approve'),
                      ),
                    if (b.canApprove && (b.canReject || b.canCancel))
                      const SizedBox(height: AppSpacing.sm),
                    if (b.canReject)
                      OutlinedButton(
                        onPressed: () => _action('reject', b.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade300),
                        ),
                        child: const Text('Reject'),
                      ),
                    if (b.canReject && b.canCancel)
                      const SizedBox(height: AppSpacing.sm),
                    if (b.canCancel)
                      OutlinedButton(
                        onPressed: () => _action('cancel', b.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade300),
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.greyText,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _action(String type, int id) async {
    final controller = ref.read(hostBookingsProvider.notifier);
    bool ok = false;
    if (type == 'approve') ok = await controller.approveBooking(id);
    if (type == 'reject') ok = await controller.rejectBooking(id);
    if (type == 'cancel') ok = await controller.cancelBooking(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '$type successful' : 'Failed to $type'),
          backgroundColor: ok ? AppTheme.secondaryGreen : Colors.red.shade700,
        ),
      );
      if (ok) Navigator.pop(context);
    }
  }
}
