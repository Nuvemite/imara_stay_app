import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/properties/models/property_details_model.dart';

/// Host Card Widget
/// Displays host information
class HostCard extends StatelessWidget {
  final HostInfo host;

  const HostCard({
    super.key,
    required this.host,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGrey),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.lightGrey,
            backgroundImage: host.avatarUrl != null && host.avatarUrl!.isNotEmpty
                ? NetworkImage(host.avatarUrl!)
                : null,
            child: (host.avatarUrl == null || (host.avatarUrl?.isEmpty ?? true)) && host.name.isNotEmpty
                ? Text(
                    host.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),

          // Host Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        host.name,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (host.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified,
                        color: AppTheme.secondaryGreen,
                        size: 20,
                      ),
                    ],
                  ],
                ),
                if ((host.bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    host.bio ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.greyText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${host.rating}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '(${host.totalReviews} reviews)',
                        style: const TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  host.responseTime,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.greyText),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  host.joinedDate,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.greyText),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Contact Button
          IconButton(
            icon: const Icon(Icons.message, color: AppTheme.primaryRed),
            onPressed: () {
              // TODO: Navigate to messaging screen
            },
            style: IconButton.styleFrom(
              minimumSize: const Size(40, 40),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
