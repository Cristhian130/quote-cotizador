import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import '../atoms/ia_input.dart';

class LabeledInput extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool isDense;

  const LabeledInput({
    super.key,
    required this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: IaColors.mutedForeground,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        IAInput(
          placeholder: placeholder,
          value: value,
          onChanged: onChanged,
          isDense: isDense,
        ),
      ],
    );
  }
}
