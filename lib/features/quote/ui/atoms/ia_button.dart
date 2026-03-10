import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';

enum IAButtonVariant { default_, outline, ghost, secondary }

class IAButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IAButtonVariant variant;
  final EdgeInsetsGeometry padding;

  const IAButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = IAButtonVariant.default_,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = IaColors.accent;
    Color foregroundColor = IaColors.accentForeground;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case IAButtonVariant.default_:
        backgroundColor = IaColors.accent;
        foregroundColor = IaColors.accentForeground;
        break;
      case IAButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = IaColors.foreground;
        borderSide = const BorderSide(color: IaColors.border);
        break;
      case IAButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = IaColors.mutedForeground;
        break;
      case IAButtonVariant.secondary:
        backgroundColor = IaColors.muted;
        foregroundColor = IaColors.foreground;
        break;
    }

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: borderSide,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        hoverColor: foregroundColor.withOpacity(0.1),
        splashColor: foregroundColor.withOpacity(0.1),
        child: Container(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor, size: 16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
