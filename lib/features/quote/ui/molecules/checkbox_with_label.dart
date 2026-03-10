import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';

class CheckboxWithLabel extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final IconData? icon;

  const CheckboxWithLabel({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: IaColors.foreground,
              side: const BorderSide(color: IaColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, size: 14, color: IaColors.mutedForeground),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: IaColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
