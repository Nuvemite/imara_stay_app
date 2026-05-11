import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_dashboard_model.dart';

/// Pie chart for booking status distribution
class HostBookingStatusChart extends StatelessWidget {
  const HostBookingStatusChart({
    super.key,
    required this.bookingStatus,
    this.size = 120,
  });

  final List<BookingStatusItem> bookingStatus;
  final double size;

  Color _parseColor(String hex) {
    try {
      final c = hex.replaceFirst('#', '');
      return Color(int.parse('FF$c', radix: 16));
    } catch (_) {
      return AppTheme.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookingStatus.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = bookingStatus.fold<int>(0, (s, e) => s + e.value);
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final sections = bookingStatus.asMap().entries.map((e) {
      return PieChartSectionData(
        value: e.value.value.toDouble(),
        title: '${e.value.value}',
        color: _parseColor(e.value.color),
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: size + 80,
      child: Column(
        children: [
          SizedBox(
            height: size,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 24,
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: bookingStatus.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _parseColor(item.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.name}: ${item.value}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
