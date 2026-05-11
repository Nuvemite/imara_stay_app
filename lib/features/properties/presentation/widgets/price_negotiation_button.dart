import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/properties/models/property_details_model.dart';

/// Price Negotiation Button
/// Unique feature - allows price negotiation
class PriceNegotiationButton extends StatelessWidget {
  final PropertyDetails property;
  final VoidCallback onTap;

  const PriceNegotiationButton({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.handshake, size: 18),
      label: const Text('Negotiate'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryRed,
        side: const BorderSide(color: AppTheme.primaryRed, width: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
