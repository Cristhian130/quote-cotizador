import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';

class IAInput extends StatelessWidget {
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final bool isDense;

  const IAInput({
    super.key,
    this.placeholder,
    this.value,
    this.onChanged,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IaColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: IaColors.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: isDense ? 8 : 10),
      child: TextField(
        controller: value != null
            ? (TextEditingController(text: value)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: value!.length),
                ))
            : null,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: IaColors.foreground),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: placeholder,
          hintStyle: const TextStyle(
            color: IaColors.mutedForeground,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
