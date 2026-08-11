import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IaSelect extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? placeholder;

  const IaSelect({
    super.key,
    required this.label,
    this.icon,
    this.value,
    required this.options,
    required this.onChanged,
    this.placeholder,
  });

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _showSelector(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim1),
            child: _IaSelectDialog(
              title: label,
              options: options,
              selectedValue: value,
              onSelected: (val) {
                onChanged(val);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
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
              Icon(icon, size: 14, color: IaColors.accent),
              const SizedBox(width: 8),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: IaColors.mutedForeground,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showSelector(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: IaColors.border),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? _capitalize(value!) : (placeholder ?? 'Seleccionar...'),
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? IaColors.foreground : IaColors.mutedForeground,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  LucideIcons.chevronsUpDown,
                  size: 16,
                  color: IaColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IaSelectDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const _IaSelectDialog({
    required this.title,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_IaSelectDialog> createState() => _IaSelectDialogState();
}

class _IaSelectDialogState extends State<_IaSelectDialog> {
  late List<String> _filteredOptions;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _filteredOptions = widget.options
          .where((opt) => opt.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 350,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar ${widget.title}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: IaColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                isDense: true,
                filled: true,
                fillColor: IaColors.muted.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _filteredOptions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No se encontraron resultados',
                          style: TextStyle(color: IaColors.mutedForeground, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final opt = _filteredOptions[index];
                        final isSelected = opt == widget.selectedValue;

                        return InkWell(
                          onTap: () => widget.onSelected(opt),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? IaColors.accent.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _capitalize(opt),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? IaColors.accent : IaColors.foreground,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    LucideIcons.check,
                                    size: 16,
                                    color: IaColors.accent,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
