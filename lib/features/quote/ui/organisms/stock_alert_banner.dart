import 'package:flutter/material.dart';
import '../../../../features/stock/data/stock_alerts_demo.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Stock Alert Banner — appears in QuotePage between SearchPanel and the table
//  Shows proactive inventory alerts derived from active business rules
// ─────────────────────────────────────────────────────────────────────────────

const Color _alertBg = Color(0xFFFEFCFF);
const Color _alertBorder = Color(0xFFE8E3FF);
const Color _purple = Color(0xFF7B5FF5);
const Color _blue = Color(0xFF458AC9);
const Color _green = Color(0xFF2BAE7E);
const Color _orange = Color(0xFFE67E22);
const Color _red = Color(0xFFE53935);
const Color _textPrimary = Color(0xFF1C2333);
const Color _textMuted = Color(0xFF6E7A8A);

class StockAlertBanner extends StatefulWidget {
  const StockAlertBanner({super.key});

  @override
  State<StockAlertBanner> createState() => _StockAlertBannerState();
}

class _StockAlertBannerState extends State<StockAlertBanner>
    with SingleTickerProviderStateMixin {
  bool _expanded = true; // open by default on first load
  bool _dismissed = false;
  late final AnimationController _ctrl;
  late final Animation<double> _heightFactor;
  late final Animation<double> _fade;

  // selected filter rule (null = all)
  String? _filterRuleId;
  // dismissed individual alert ids
  final Set<String> _dismissedAlerts = {};

  List<StockAlert> get _allAlerts => generateAlerts();

  List<StockAlert> get _visibleAlerts {
    return _allAlerts.where((a) {
      if (_dismissedAlerts.contains(_alertKey(a))) return false;
      if (_filterRuleId != null && a.regla.id != _filterRuleId) return false;
      return true;
    }).toList();
  }

  String _alertKey(StockAlert a) => '${a.regla.id}__${a.item.referencia}';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0, // start open
    );
    _heightFactor = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_expanded) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _expanded = !_expanded);
  }

  Color _ruleColor(StockAlertType tipo) {
    switch (tipo) {
      case StockAlertType.sinExistencia: return _red;
      case StockAlertType.stockCritico: return _orange;
      case StockAlertType.inmovilizado: return _purple;
      case StockAlertType.sobrestock: return _orange;
      case StockAlertType.altaDemanda: return _blue;
      case StockAlertType.enTransito: return _green;
    }
  }

  IconData _ruleIcon(StockAlertType tipo) {
    switch (tipo) {
      case StockAlertType.sinExistencia: return Icons.remove_shopping_cart;
      case StockAlertType.stockCritico: return Icons.warning_amber_rounded;
      case StockAlertType.inmovilizado: return Icons.hourglass_bottom_rounded;
      case StockAlertType.sobrestock: return Icons.inventory_2_rounded;
      case StockAlertType.altaDemanda: return Icons.trending_up_rounded;
      case StockAlertType.enTransito: return Icons.local_shipping_rounded;
    }
  }

  Color _accionColor(StockAlertAccion accion) {
    switch (accion) {
      case StockAlertAccion.descuento: return _green;
      case StockAlertAccion.traslado: return _blue;
      case StockAlertAccion.priorizar: return _purple;
      case StockAlertAccion.reposicion: return _orange;
      case StockAlertAccion.liquidacion: return _red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final alerts = _visibleAlerts;
    final allAlerts = _allAlerts;
    final uniqueRules = kDemoAlertRules.where(
      (r) => allAlerts.any((a) => a.regla.id == r.id),
    ).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: _alertBg,
        border: Border(
          bottom: BorderSide(color: _alertBorder, width: 1.5),
          left: BorderSide(color: _purple, width: 3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.transparent,
              child: Row(
                children: [
                  // Pulse dot
                  _PulseDot(color: _purple),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: _purple.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'SMART INSIGHTS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _purple,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${allAlerts.length} alertas de inventario — Bodega PV122',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Rule filter chips
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Todas',
                            color: _textMuted,
                            selected: _filterRuleId == null,
                            onTap: () =>
                                setState(() => _filterRuleId = null),
                          ),
                          ...uniqueRules.map((r) => _FilterChip(
                                label: r.nombre.split(' ').first,
                                color: _ruleColor(r.tipo),
                                selected: _filterRuleId == r.id,
                                onTap: () => setState(() =>
                                    _filterRuleId = _filterRuleId == r.id
                                        ? null
                                        : r.id),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expand/collapse
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_less_rounded,
                        size: 18, color: _textMuted),
                  ),
                  const SizedBox(width: 8),
                  // Dismiss banner
                  GestureDetector(
                    onTap: () => setState(() => _dismissed = true),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: _textMuted),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible alert list ─────────────────────────────────────────
          SizeTransition(
            sizeFactor: _heightFactor,
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                child: alerts.isEmpty
                    ? _EmptyFilter()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                        shrinkWrap: true,
                        itemCount: alerts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 6),
                        itemBuilder: (ctx, i) {
                          final alert = alerts[i];
                          return _AlertTile(
                            alert: alert,
                            ruleColor: _ruleColor(alert.regla.tipo),
                            ruleIcon: _ruleIcon(alert.regla.tipo),
                            accionColor: _accionColor(alert.regla.accion),
                            onDismiss: () => setState(() =>
                                _dismissedAlerts.add(_alertKey(alert))),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulse dot ─────────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.3).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 * _scale.value),
                blurRadius: 6 * _scale.value,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      );
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border:
                Border.all(color: selected ? color.withOpacity(0.4) : const Color(0xFFDDE1E8)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? color : _textMuted,
            ),
          ),
        ),
      );
}

// ── Individual alert tile ─────────────────────────────────────────────────────

class _AlertTile extends StatefulWidget {
  final StockAlert alert;
  final Color ruleColor;
  final IconData ruleIcon;
  final Color accionColor;
  final VoidCallback onDismiss;

  const _AlertTile({
    required this.alert,
    required this.ruleColor,
    required this.ruleIcon,
    required this.accionColor,
    required this.onDismiss,
  });

  @override
  State<_AlertTile> createState() => _AlertTileState();
}

class _AlertTileState extends State<_AlertTile> {
  bool _hovered = false;
  bool _applied = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.alert.item;
    final regla = widget.alert.regla;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.ruleColor.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: _hovered
                ? widget.ruleColor.withOpacity(0.3)
                : const Color(0xFFE8ECF0),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.ruleColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Rule type icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.ruleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(widget.ruleIcon,
                  size: 14, color: widget.ruleColor),
            ),
            const SizedBox(width: 9),

            // Product + rule info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.descripcion,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Existence badge
                      _MiniChip(
                        label: 'Stock: ${item.existencia.toInt()} ${item.unidad}',
                        color: item.existencia == 0 ? _red : _textMuted,
                      ),
                      const SizedBox(width: 4),
                      _MiniChip(
                        label: item.clasificacion,
                        color: item.clasificacion == 'ZZ' || item.clasificacion == 'Z'
                            ? _orange
                            : _green,
                      ),
                      if (item.cantTransito > 0) ...[
                        const SizedBox(width: 4),
                        _MiniChip(
                          label: '+${item.cantTransito.toInt()} tránsito',
                          color: _blue,
                        ),
                      ],
                      if (item.diasSinMovimiento > 90) ...[
                        const SizedBox(width: 4),
                        _MiniChip(
                          label: '${item.diasSinMovimiento}d sin mov.',
                          color: _purple,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    regla.nombre,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: widget.ruleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action button
            GestureDetector(
              onTap: () => setState(() => _applied = !_applied),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _applied
                      ? const Color(0xFFF4F5F7)
                      : widget.accionColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _applied
                        ? const Color(0xFFDDE1E8)
                        : widget.accionColor,
                  ),
                ),
                child: Text(
                  _applied ? '✓ Aplicado' : widget.alert.accionTexto,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: _applied ? _textMuted : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Dismiss individual
            GestureDetector(
              onTap: widget.onDismiss,
              child: const Icon(Icons.close_rounded,
                  size: 13, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );
}

class _EmptyFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        alignment: Alignment.center,
        child: const Text(
          'No hay alertas para este filtro',
          style: TextStyle(fontSize: 12, color: _textMuted),
        ),
      );
}
