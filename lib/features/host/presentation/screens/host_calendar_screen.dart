import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';

/// Host calendar - GET/POST /api/host/listings/{id}/calendar
class HostCalendarScreen extends StatefulWidget {
  const HostCalendarScreen({super.key, required this.listingId});

  final int listingId;

  @override
  State<HostCalendarScreen> createState() => _HostCalendarScreenState();
}

class _HostCalendarScreenState extends State<HostCalendarScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ApiConfig.useApi) {
      setState(() {
        _loading = false;
        _data = null;
        _error = 'API not enabled';
      });
      return;
    }

    final token = await AuthController.getStoredToken();
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'Not authenticated';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.url('/host/listings/${widget.listingId}/calendar')),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          setState(() {
            _data = data;
            _loading = false;
            _error = null;
          });
        } else {
          setState(() {
            _loading = false;
            _error = 'Failed to load calendar';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final bookings = _data!['bookings'] as List? ?? [];
    final blockedDates = _data!['blocked_dates'] as List? ?? [];
    final listing = _data!['listing'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(listing['title']?.toString() ?? 'Calendar'),
        backgroundColor: AppTheme.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Bookings',
              bookings.isEmpty
                  ? const Text('No upcoming bookings')
                  : Column(
                      children: bookings.map<Widget>((b) {
                        final bm = b as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Text(
                                '${bm['start_date']} – ${bm['end_date']}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bm['guest_name']?.toString() ?? 'Guest',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.greyText),
                              ),
                              const Spacer(),
                              Text(
                                'KES ${bm['total_price'] ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSection(
              context,
              'Blocked dates',
              blockedDates.isEmpty
                  ? const Text('No blocked dates')
                  : Wrap(
                      spacing: 8,
                      children: blockedDates.map<Widget>((b) {
                        final bm = b as Map<String, dynamic>;
                        return Chip(
                          label: Text(bm['date']?.toString() ?? ''),
                          onDeleted: () {},
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'To block dates, use the web dashboard or contact support.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.greyText,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Widget child,
  ) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
