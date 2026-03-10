import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/ia_colors.dart';
import '../../models/product_item.dart';
import '../atoms/ia_badge.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

const Color _neonBlue = Color(0xFF458AC9);

class ProductTable extends StatelessWidget {
  final List<ProductItem> items;
  final void Function(String id, int cantidad) onUpdateCantidad;
  final void Function(String id, double descuento) onUpdateDescuento;
  final void Function(String id) onRemoveItem;

  const ProductTable({
    super.key,
    required this.items,
    required this.onUpdateCantidad,
    required this.onUpdateDescuento,
    required this.onRemoveItem,
  });

  String _formatCurrency(double value) {
    return NumberFormat.simpleCurrency(
      locale: 'es_CO',
      name: '',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: IaColors.card,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: items.isEmpty ? _buildEmptyState() : _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: IaColors.accent.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _h('REFERENCIA', flex: 2),
          _h('DESCRIPCION', flex: 3),
          _h('BODEGA', flex: 1, a: TextAlign.center),
          _h('DISP.', flex: 1, a: TextAlign.center),
          _h('UBIC.', flex: 1, a: TextAlign.center),
          _h('P. UNIT.', flex: 1, a: TextAlign.right),
          _h('DESC. %', flex: 1, a: TextAlign.right),
          _h('DESC. APLIC.', flex: 1, a: TextAlign.right),
          _h('CANT.', flex: 1, a: TextAlign.center),
          _h('TOTAL', flex: 1, a: TextAlign.right),
          _h('P.X UNID.', flex: 1, a: TextAlign.right),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _h(String t, {int flex = 1, TextAlign a = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        t,
        textAlign: a,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: IaColors.mutedForeground,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _neonBlue.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: _neonBlue.withOpacity(0.2)),
            ),
            child: const Icon(
              LucideIcons.packageOpen,
              color: _neonBlue,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sin productos agregados',
            style: TextStyle(fontSize: 14, color: IaColors.mutedForeground),
          ),
          const SizedBox(height: 4),
          const Text(
            'Usa el buscador para agregar a la factura',
            style: TextStyle(fontSize: 12, color: IaColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => _GlowingRow(
        key: ValueKey(items[i].id),
        item: items[i],
        onUpdateCantidad: onUpdateCantidad,
        onUpdateDescuento: onUpdateDescuento,
        onRemoveItem: onRemoveItem,
        formatCurrency: _formatCurrency,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Row with always-on breathing neon glow border
// ─────────────────────────────────────────────────────────
class _GlowingRow extends StatefulWidget {
  final ProductItem item;
  final void Function(String, int) onUpdateCantidad;
  final void Function(String, double) onUpdateDescuento;
  final void Function(String) onRemoveItem;
  final String Function(double) formatCurrency;

  const _GlowingRow({
    super.key,
    required this.item,
    required this.onUpdateCantidad,
    required this.onUpdateDescuento,
    required this.onRemoveItem,
    required this.formatCurrency,
  });

  @override
  State<_GlowingRow> createState() => _GlowingRowState();
}

class _GlowingRowState extends State<_GlowingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    // Random phase offset so rows don't pulse in sync
    _glow.value = Random().nextDouble();
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, child) {
          final t = _glow.value; // 0→1→0 breathing
          // base ambient glow
          final ambientOpacity = 0.07 + t * 0.09;
          final ambientBlur = 10.0 + t * 14.0;
          // hover boost
          final hoverExtra = _hovered ? 0.18 : 0.0;
          final borderOpacity = (_hovered ? 0.55 : (0.15 + t * 0.18)).clamp(
            0.0,
            1.0,
          );

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _hovered
                  ? _neonBlue.withOpacity(0.035)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _neonBlue.withOpacity(borderOpacity),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _neonBlue.withOpacity(ambientOpacity + hoverExtra),
                  blurRadius: ambientBlur + (_hovered ? 10 : 0),
                  spreadRadius: _hovered ? 1 : 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SelectionArea(
            child: Row(
              children: [
                // REFERENCIA
                Expanded(
                  flex: 2,
                  child: Text(
                    item.referencia,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: IaColors.mutedForeground,
                    ),
                  ),
                ),
                // DESCRIPCION
                Expanded(
                  flex: 3,
                  child: Text(
                    item.descripcion,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // BODEGA
                Expanded(
                  flex: 1,
                  child: Center(
                    child: IABadge(
                      text: item.bodega,
                      variant: IABadgeVariant.secondary,
                    ),
                  ),
                ),
                // DISP.
                Expanded(
                  flex: 1,
                  child: Text(
                    item.disponible.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                // UBIC.
                Expanded(
                  flex: 1,
                  child: Text(
                    item.ubicacion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: IaColors.mutedForeground,
                    ),
                  ),
                ),
                // P. UNIT.
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.formatCurrency(item.precioUnitario),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                // DESC. %
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 68,
                      child: _DescuentoField(
                        item: item,
                        onUpdateDescuento: widget.onUpdateDescuento,
                      ),
                    ),
                  ),
                ),
                // DESC. APLICADO
                Expanded(
                  flex: 1,
                  child: Text(
                    '-${widget.formatCurrency(item.descuentoAplicado)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: IaColors.destructive,
                    ),
                  ),
                ),
                // CANTIDAD
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconBtn(
                        LucideIcons.minus,
                        () => widget.onUpdateCantidad(
                          item.id,
                          (item.cantidad - 1).clamp(1, 9999),
                        ),
                      ),
                      SizedBox(
                        width: 26,
                        child: Text(
                          item.cantidad.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _iconBtn(
                        LucideIcons.plus,
                        () =>
                            widget.onUpdateCantidad(item.id, item.cantidad + 1),
                      ),
                    ],
                  ),
                ),
                // TOTAL
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.formatCurrency(item.precioTotal),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: _hovered ? _neonBlue : IaColors.foreground,
                    ),
                  ),
                ),
                // P.X UNID.
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.formatCurrency(item.precioXUnidad),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                // BORRAR
                SizedBox(
                  width: 44,
                  child: IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 15),
                    color: IaColors.mutedForeground,
                    hoverColor: IaColors.destructive.withOpacity(0.12),
                    tooltip: 'Eliminar',
                    onPressed: () => widget.onRemoveItem(item.id),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, size: 14, color: IaColors.mutedForeground),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Editable discount % field
// ─────────────────────────────────────────────────────────
class _DescuentoField extends StatefulWidget {
  final ProductItem item;
  final void Function(String, double) onUpdateDescuento;

  const _DescuentoField({required this.item, required this.onUpdateDescuento});

  @override
  State<_DescuentoField> createState() => _DescuentoFieldState();
}

class _DescuentoFieldState extends State<_DescuentoField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.item.descuento.toInt().toString(),
    );
  }

  @override
  void didUpdateWidget(_DescuentoField old) {
    super.didUpdateWidget(old);
    if (old.item.descuento != widget.item.descuento) {
      _ctrl.text = widget.item.descuento.toInt().toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _apply(String val) {
    final d = double.tryParse(val) ?? 0;
    widget.onUpdateDescuento(widget.item.id, d.clamp(0, 100));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
      decoration: InputDecoration(
        suffixText: '%',
        suffixStyle: const TextStyle(
          fontSize: 11,
          color: IaColors.mutedForeground,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: IaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: _neonBlue),
        ),
      ),
      onChanged: (v) {
        final d = double.tryParse(v);
        if (d != null)
          widget.onUpdateDescuento(widget.item.id, d.clamp(0, 100));
      },
      onSubmitted: _apply,
      onTapOutside: (_) {
        _apply(_ctrl.text);
        FocusScope.of(context).unfocus();
      },
    );
  }
}
