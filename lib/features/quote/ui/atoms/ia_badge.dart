import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';

enum IABadgeVariant { default_, secondary, outline }

class IABadge extends StatelessWidget {
  final String text;
  final IABadgeVariant variant;

  const IABadge({
    super.key,
    required this.text,
    this.variant = IABadgeVariant.default_,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case IABadgeVariant.default_:
        backgroundColor = IaColors.primary;
        foregroundColor = IaColors.primaryForeground;
        break;
      case IABadgeVariant.secondary:
        backgroundColor = IaColors.muted;
        foregroundColor = IaColors.foreground;
        break;
      case IABadgeVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = IaColors.foreground;
        borderSide = const BorderSide(color: IaColors.border);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: borderSide != BorderSide.none
            ? Border.fromBorderSide(borderSide)
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
