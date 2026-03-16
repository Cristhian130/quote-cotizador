import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import '../atoms/ia_input.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchableSelector extends StatefulWidget {
  final String label;
  final String? placeholder;
  final List<String> items;
  final String? value;
  final ValueChanged<String> onSelected;

  const SearchableSelector({
    super.key,
    required this.label,
    this.placeholder,
    required this.items,
    this.value,
    required this.onSelected,
  });

  @override
  State<SearchableSelector> createState() => _SearchableSelectorState();
}

class _SearchableSelectorState extends State<SearchableSelector> {
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(
        title: widget.label,
        items: widget.items,
        onSelected: widget.onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: IaColors.mutedForeground,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _showSearchDialog,
          borderRadius: BorderRadius.circular(8),
          child: IgnorePointer(
            child: IAInput(
              placeholder: widget.placeholder,
              value: widget.value,
              suffixIcon: const Icon(LucideIcons.chevronDown, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _SearchDialog({
    required this.title,
    required this.items,
    required this.onSelected,
  });

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late List<String> _filteredItems;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionar ${widget.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                )
              ],
            ),
            const SizedBox(height: 12),
            IAInput(
              controller: _searchCtrl,
              placeholder: 'Buscar...',
              onChanged: _filter,
              prefixIcon: const Icon(LucideIcons.search, size: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      widget.onSelected(item);
                      Navigator.pop(context);
                    },
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
