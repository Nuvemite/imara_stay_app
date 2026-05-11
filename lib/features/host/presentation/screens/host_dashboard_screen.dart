import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/core/widgets/imara_stay_logo.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/host/models/host_dashboard_model.dart';
import 'package:imara_stay/features/host/presentation/widgets/host_alert_card.dart';
import 'package:imara_stay/features/host/presentation/widgets/host_booking_status_chart.dart';
import 'package:imara_stay/features/host/presentation/widgets/host_earnings_chart.dart';
import 'package:imara_stay/features/host/presentation/widgets/host_stat_card.dart';
import 'package:imara_stay/features/host/presentation/widgets/recent_booking_tile.dart';
import 'package:imara_stay/features/host/state/host_dashboard_controller.dart';
import 'package:imara_stay/features/listings/presentation/screens/listing_type_selection_screen.dart';

/// Host Dashboard - Welcome, alerts, stats, recent bookings & reviews
class HostDashboardScreen extends ConsumerWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(hostDashboardProvider);
    final dashboardController = ref.read(hostDashboardProvider.notifier);

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
      body: dashboardState.isLoading && dashboardState.data == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : RefreshIndicator(
              onRefresh: () => dashboardController.loadDashboard(),
              color: AppTheme.primaryRed,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcome(context, ref, dashboardState.data),
                    const SizedBox(height: AppSpacing.lg),
                    if (dashboardState.error != null)
                      _buildError(context, dashboardState.error!),
                    if (dashboardState.data != null) ...[
                      if (dashboardState.data!.alerts.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Action Required'),
                        const SizedBox(height: AppSpacing.sm),
                        ...dashboardState.data!.alerts
                            .map((a) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: HostAlertCard(alert: a),
                                )),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      _buildSectionTitle(context, 'Overview'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildStatsGrid(context, dashboardState.data!),
                      if (dashboardState.data!.charts != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _buildSectionTitle(context, 'Weekly Earnings'),
                        const SizedBox(height: AppSpacing.sm),
                        _buildChartsSection(context, dashboardState.data!.charts!),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle(context, 'Optimization Tips'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildOptimizationTips(context),
                      if (dashboardState.data!.listingPerformance != null &&
                          dashboardState.data!.listingPerformance!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _buildSectionTitle(context, 'Listing Performance'),
                        const SizedBox(height: AppSpacing.sm),
                        _buildListingPerformance(
                            context, dashboardState.data!.listingPerformance!),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle(context, 'Recent Bookings'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildRecentBookings(context, dashboardState.data!),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle(context, 'Recent Reviews'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildRecentReviews(context, dashboardState.data!),
                      const SizedBox(height: AppSpacing.xl),
                      _buildAddListingCta(context),
                    ] else if (!dashboardState.isLoading) ...[
                      _buildAddListingCta(context),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcome(
    BuildContext context,
    WidgetRef ref,
    HostDashboardModel? data,
  ) {
    final name = data?.userName ?? ref.read(authProvider).user?.name ?? 'Host';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Karibu, $name!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your hosting overview.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.greyText,
              ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, HostDashboardModel data) {
    final f = data.financial;
    final b = data.bookings;
    final r = data.rating;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HostStatCard(
                label: 'Earnings (this month)',
                value: 'KES ${f.grossEarnings}',
                changePercent: f.earningsChange,
                icon: Icons.attach_money,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: HostStatCard(
                label: 'Occupancy',
                value: '${f.occupancyRate}%',
                icon: Icons.pie_chart_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: HostStatCard(
                label: 'Total Bookings',
                value: '${b.total}',
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: HostStatCard(
                label: 'Rating',
                value: r.average,
                icon: Icons.star,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptimizationTips(BuildContext context) {
    const tips = [
      ('Add more photos', 'Listings with 5+ photos get 3x more views'),
      ('Respond quickly', 'Reply within an hour to improve conversion'),
      ('Update calendar', 'Keep your availability up to date'),
      ('Set competitive pricing', 'Check similar listings in your area'),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: tips.map((t) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 20, color: AppTheme.primaryRed),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.$1,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        t.$2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.greyText,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListingPerformance(
    BuildContext context,
    List<ListingPerformance> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.take(5).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'KES ${item.revenue}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryRed,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${item.occupancy}% occ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.greyText,
                      ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                Text('${item.rating}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, HostCharts charts) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (charts.weeklyEarnings.isNotEmpty)
            HostEarningsChart(weeklyEarnings: charts.weeklyEarnings),
          if (charts.weeklyEarnings.isNotEmpty && charts.bookingStatus.isNotEmpty)
            const SizedBox(height: AppSpacing.xl),
          if (charts.bookingStatus.isNotEmpty)
            HostBookingStatusChart(bookingStatus: charts.bookingStatus),
        ],
      ),
    );
  }

  Widget _buildRecentBookings(BuildContext context, HostDashboardModel data) {
    final bookings = data.recentBookings;
    if (bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: AppTheme.greyText.withValues(alpha: 0.5)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No recent bookings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.greyText,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: bookings.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppTheme.lightGrey),
        itemBuilder: (context, i) {
          return RecentBookingTile(booking: bookings[i]);
        },
      ),
    );
  }

  Widget _buildRecentReviews(BuildContext context, HostDashboardModel data) {
    final reviews = data.recentReviews;
    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.rate_review, size: 48, color: AppTheme.greyText.withValues(alpha: 0.5)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No reviews yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.greyText,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: reviews
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          r.guest,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          r.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const Spacer(),
                        Text(
                          r.date,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.greyText,
                              ),
                        ),
                      ],
                    ),
                    if (r.comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        r.comment,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.greyText,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAddListingCta(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ListingTypeSelectionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryRed,
          side: const BorderSide(color: AppTheme.primaryRed),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        ),
      ),
    );
  }
}
