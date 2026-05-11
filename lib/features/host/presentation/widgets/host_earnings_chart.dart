import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_dashboard_model.dart';

/// Bar chart for weekly earnings
class HostEarningsChart extends StatelessWidget {
  const HostEarningsChart({
    super.key,
    required this.weeklyEarnings,
    this.height = 180,
  });

  final List<WeeklyEarning> weeklyEarnings;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (weeklyEarnings.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxEarnings = weeklyEarnings
        .map((e) => e.earnings)
        .reduce((a, b) => a > b ? a : b);
    final maxY = maxEarnings > 0 ? (maxEarnings * 1.2).ceil() : 10;

    final barGroups = weeklyEarnings.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.earnings.toDouble(),
            color: AppTheme.primaryRed,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return Container(
      height: height,
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY.toDouble(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.darkText,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = weeklyEarnings[group.x];
                return BarTooltipItem(
                  '${item.name}\nKES ${item.earnings}\n${item.bookings} bookings',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < weeklyEarnings.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        weeklyEarnings[value.toInt()].name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.greyText,
                            ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 28,
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value >= 1000 ? '${(value / 1000).toInt()}k' : value.toInt().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.greyText,
                        ),
                  );
                },
                interval: maxY / 4,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.lightGrey,
              strokeWidth: 1,
            ),
          ),
          barGroups: barGroups,
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
