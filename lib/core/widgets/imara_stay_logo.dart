import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';

/// Reusable ImaraStay logo placeholder.
/// Replace with an image asset when the final logo is ready.
class ImaraStayLogo extends StatelessWidget {
  const ImaraStayLogo({
    super.key,
    this.size = ImaraStayLogoSize.medium,
    this.showIcon = true,
  });

  final ImaraStayLogoSize size;
  final bool showIcon;

  double get _fontSize {
    switch (size) {
      case ImaraStayLogoSize.small:
        return 18;
      case ImaraStayLogoSize.medium:
        return 24;
      case ImaraStayLogoSize.large:
        return 32;
    }
  }

  double get _iconSize {
    switch (size) {
      case ImaraStayLogoSize.small:
        return 20;
      case ImaraStayLogoSize.medium:
        return 32;
      case ImaraStayLogoSize.large:
        return 48;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showIcon) ...[
          Icon(
            Icons.home_work_rounded,
            color: AppTheme.primaryRed,
            size: _iconSize,
          ),
          SizedBox(width: size == ImaraStayLogoSize.small ? 6 : 10),
        ],
        Text(
          'ImaraStay',
          style: TextStyle(
            color: AppTheme.primaryRed,
            fontSize: _fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

enum ImaraStayLogoSize { small, medium, large }
