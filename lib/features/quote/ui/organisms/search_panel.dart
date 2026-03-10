import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import '../molecules/labeled_input.dart';
import '../atoms/ia_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchPanel extends StatelessWidget {
  final String referencia;
  final ValueChanged<String> setReferencia;
  final String descripcion;
  final ValueChanged<String> setDescripcion;
  final String bodega;
  final ValueChanged<String> setBodega;
  final VoidCallback onBuscar;

  const SearchPanel({
    super.key,
    required this.referencia,
    required this.setReferencia,
    required this.descripcion,
    required this.setDescripcion,
    required this.bodega,
    required this.setBodega,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: IaColors.card,
        border: Border(bottom: BorderSide(color: IaColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 1,
            child: LabeledInput(
              label: 'Referencia',
              placeholder: 'Buscar por referencia...',
              value: referencia,
              onChanged: setReferencia,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: LabeledInput(
              label: 'Descripcion',
              placeholder: 'Buscar por descripcion...',
              value: descripcion,
              onChanged: setDescripcion,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: LabeledInput(
              label: 'Bodega',
              placeholder: 'Bodega...',
              value: bodega,
              onChanged: setBodega,
            ),
          ),
          const SizedBox(width: 12),
          IAButton(
            onPressed: onBuscar,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9.5),
            child: const Row(
              children: [
                Icon(LucideIcons.search),
                SizedBox(width: 8),
                Text('Buscar'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
