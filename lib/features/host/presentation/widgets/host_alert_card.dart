import 'package:flutter/material.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/host/models/host_dashboard_model.dart';

/// Alert card for host dashboard (urgent, warning)
class HostAlertCard extends StatelessWidget {
  const HostAlertCard({super.key, required this.alert});

  final HostAlert alert;

  Color get _backgroundColor {
    switch (alert.type) {
      case 'urgent':
        return Colors.red.shade50;
      case 'warning':
        return Colors.amber.shade50;
      default:
        return AppTheme.lightGrey;
    }
  }

  Color get _accentColor {
    switch (alert.type) {
      case 'urgent':
        return Colors.red.shade700;
      case 'warning':
        return Colors.amber.shade700;
      default:
        return AppTheme.primaryRed;
    }
  }

  IconData get _icon {
    switch (alert.icon) {
      case 'key':
        return Icons.key;
      case 'notifications':
        return Icons.notifications;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(_icon, color: _accentColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                ),
                if (alert.desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    alert.desc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyText,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
