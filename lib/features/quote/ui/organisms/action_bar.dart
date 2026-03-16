import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import '../atoms/ia_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActionBar extends StatelessWidget {
  final VoidCallback onCalcular;
  final VoidCallback? onDescargar;
  final VoidCallback onLimpiar;
  final VoidCallback onAnadirClientes;
  final VoidCallback onSincronizar;

  const ActionBar({
    super.key,
    required this.onCalcular,
    this.onDescargar,
    required this.onLimpiar,
    required this.onAnadirClientes,
    required this.onSincronizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: IaColors.card,
        border: Border(top: BorderSide(color: IaColors.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          IAButton(
            variant: IAButtonVariant.outline,
            onPressed: onAnadirClientes,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.userPlus),
                SizedBox(width: 8),
                Text('Clientes'),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IAButton(
                variant: IAButtonVariant.outline,
                onPressed: onSincronizar,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.refreshCw),
                    SizedBox(width: 8),
                    Text('Sincronizar Base Local'),
                  ],
                ),
              ),
              IAButton(
                variant: IAButtonVariant.ghost,
                onPressed: onLimpiar,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.eraser),
                    SizedBox(width: 8),
                    Text('Limpiar'),
                  ],
                ),
              ),
              IAButton(
                variant: IAButtonVariant.outline,
                onPressed: onDescargar,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.download),
                    SizedBox(width: 8),
                    Text('Descargar'),
                  ],
                ),
              ),
              IAButton(
                onPressed: onCalcular,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calculator),
                    SizedBox(width: 8),
                    Text('Calcular'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
