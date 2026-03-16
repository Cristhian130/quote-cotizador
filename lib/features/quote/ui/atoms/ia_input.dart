import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';

class IAInput extends StatelessWidget {
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isDense;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const IAInput({
    super.key,
    this.placeholder,
    this.value,
    this.onChanged,
    this.onSubmitted,
    this.isDense = false,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveController = controller ??
        (value != null
            ? (TextEditingController(text: value)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: value!.length),
              ))
            : null);

    return Container(
      decoration: BoxDecoration(
        color: IaColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: IaColors.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: isDense ? 8 : 10),
      child: TextField(
        controller: effectiveController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
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
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: prefixIcon,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}
