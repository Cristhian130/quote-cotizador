import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LabeledSelect extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const LabeledSelect({
    super.key,
    required this.label,
    this.icon,
    this.value,
    required this.options,
    required this.onChanged,
  });

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: IaColors.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(
                  0xFF4A6582,
                ), // Darker text color matching the image
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: IaColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                LucideIcons.chevronDown,
                size: 16,
                color: IaColors.mutedForeground,
              ),
              borderRadius: BorderRadius.circular(8),
              dropdownColor: Colors.white,
              elevation: 4,
              selectedItemBuilder: (BuildContext context) {
                return options.map<Widget>((String item) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _capitalize(item),
                      style: const TextStyle(
                        fontSize: 14,
                        color: IaColors.foreground,
                      ),
                    ),
                  );
                }).toList();
              },
              items: options.map((opt) {
                final isSelected = opt == value;
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF458AC9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _capitalize(opt),
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : IaColors.foreground,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            LucideIcons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
