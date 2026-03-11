import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ──────────────────────────────────────────────
//  IA Stock Module — ERPNext-inspired layout
// ──────────────────────────────────────────────

const Color _blue = Color(0xFF458AC9);
const Color _darkBlue = Color(0xFF192D4D);
const Color _sidebarBg = Color(0xFFFFFFFF);
const Color _sidebarBorder = Color(0xFFE2E4E9);
const Color _bodyBg = Color(0xFFF4F5F7);
const Color _textMuted = Color(0xFF8A94A6);
const Color _textPrimary = Color(0xFF1C2333);
const Color _activeItem = Color(0xFF458AC9);
const Color _hoverBg = Color(0xFFF0F4F9);

// ── Menu item models ──────────────────────────

enum _ItemType { link, group }

class _MenuItem {
  final String id;
  final String label;
  final IconData? icon;
  final _ItemType type;
  final List<_MenuItem> children;
  final String? tooltip;

  const _MenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.type = _ItemType.link,
    this.children = const [],
    this.tooltip,
  });
}

// ──────────────────────────────────────────────
//  Data
// ──────────────────────────────────────────────

const List<_MenuItem> _menu = [
  _MenuItem(id: 'dashboard', label: 'Dashboard', icon: Icons.bar_chart_rounded),
  _MenuItem(
    id: 'transaccion',
    label: 'Transacción de Stock',
    icon: Icons.swap_horiz_rounded,
  ),
  _MenuItem(
    id: 'recibo',
    label: 'Recibo de Compra',
    icon: Icons.receipt_rounded,
  ),
  _MenuItem(
    id: 'salida',
    label: 'Salida por Venta',
    icon: Icons.output_rounded,
  ),
  _MenuItem(
    id: 'solicitud',
    label: 'Solicitar Referencia',
    icon: Icons.add_shopping_cart_rounded,
  ),
  _MenuItem(
    id: 'ajuste',
    label: 'Ajuste',
    icon: Icons.tune_rounded,
    type: _ItemType.group,
    children: [
      _MenuItem(
        id: 'regulacion',
        label: 'Regulación de Stock',
        tooltip: 'Ajuste manual de cantidades en inventario.',
      ),
      _MenuItem(
        id: 'costos',
        label: 'Comprobante de Costos Adicionales',
        tooltip:
            'Distribuye costos adicionales (flete, aduanas, seguros) al inventario.',
      ),
      _MenuItem(
        id: 'recalcular',
        label: 'Recalcular Valoración de Artículos',
        tooltip:
            'Reprocesa el valor del inventario cuando hay inconsistencias.',
      ),
      _MenuItem(
        id: 'empaque',
        label: 'Lista de Empaque',
        tooltip: 'Detalla los productos enviados en un despacho.',
      ),
      _MenuItem(
        id: 'calidad',
        label: 'Inspección de Calidad',
        tooltip: 'Registro de verificación de calidad de productos.',
      ),
    ],
  ),
];

// ──────────────────────────────────────────────
//  Stock Screen
// ──────────────────────────────────────────────

class StockScreen extends StatefulWidget {
  final VoidCallback onBack;

  const StockScreen({super.key, required this.onBack});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with TickerProviderStateMixin {
  String _activeId = 'dashboard';
  bool _ajusteExpanded = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late final AnimationController _contentFadeCtrl;
  late final Animation<double> _contentFade;
  late final AnimationController _contentSlideCtrl;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _contentSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _contentFade = CurvedAnimation(
      parent: _contentFadeCtrl,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0.015, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentSlideCtrl,
            curve: Curves.easeOutCubic,
          ),
        );
    _contentFadeCtrl.forward();
    _contentSlideCtrl.forward();
  }

  @override
  void dispose() {
    _contentFadeCtrl.dispose();
    _contentSlideCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _navigate(String id) {
    if (id == _activeId) return;
    _contentFadeCtrl.forward(from: 0);
    _contentSlideCtrl.forward(from: 0);
    setState(() => _activeId = id);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            _FocusSearchIntent(),
      },
      child: Actions(
        actions: {
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_) => _searchFocus.requestFocus(),
          ),
        },
        child: Scaffold(
          backgroundColor: _bodyBg,
          body: Row(
            children: [
              // ── Left Sidebar ──────────────────
              _Sidebar(
                activeId: _activeId,
                ajusteExpanded: _ajusteExpanded,
                onNavigate: _navigate,
                onToggleAjuste: () =>
                    setState(() => _ajusteExpanded = !_ajusteExpanded),
                searchCtrl: _searchCtrl,
                searchFocus: _searchFocus,
                onBack: widget.onBack,
              ),
              // ── Main Content ──────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(activeId: _activeId),
                    Expanded(
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: _ContentArea(activeId: _activeId),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Sidebar
// ──────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final String activeId;
  final bool ajusteExpanded;
  final void Function(String) onNavigate;
  final VoidCallback onToggleAjuste;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final VoidCallback onBack;

  const _Sidebar({
    required this.activeId,
    required this.ajusteExpanded,
    required this.onNavigate,
    required this.onToggleAjuste,
    required this.searchCtrl,
    required this.searchFocus,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: _sidebarBg,
        border: Border(right: BorderSide(color: _sidebarBorder, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Module badge
          _ModuleBadge(onBack: onBack),
          const Divider(height: 1, color: _sidebarBorder),

          // Search
          _SidebarSearch(ctrl: searchCtrl, focus: searchFocus),
          const Divider(height: 1, color: _sidebarBorder),

          // Notification
          _SidebarItem(
            icon: Icons.notifications_none_rounded,
            label: 'Notificación',
            id: 'notificacion',
            activeId: activeId,
            onTap: () => onNavigate('notificacion'),
          ),

          const SizedBox(height: 4),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                for (final item in _menu) ...[
                  if (item.type == _ItemType.link)
                    _SidebarItem(
                      icon: item.icon!,
                      label: item.label,
                      id: item.id,
                      activeId: activeId,
                      onTap: () => onNavigate(item.id),
                    )
                  else
                    _SidebarGroup(
                      item: item,
                      expanded: ajusteExpanded,
                      activeId: activeId,
                      onToggle: onToggleAjuste,
                      onNavigate: onNavigate,
                    ),
                ],
              ],
            ),
          ),

          // Footer
          const Divider(height: 1, color: _sidebarBorder),
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _ModuleBadge extends StatelessWidget {
  final VoidCallback onBack;

  const _ModuleBadge({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warehouse_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Stock',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  'Importadoras Asociadas',
                  style: TextStyle(fontSize: 10, color: _textMuted),
                ),
              ],
            ),
          ),
          // Back to home
          _HoverIcon(
            icon: Icons.arrow_back_ios_new_rounded,
            size: 14,
            onTap: onBack,
          ),
        ],
      ),
    );
  }
}

class _SidebarSearch extends StatefulWidget {
  final TextEditingController ctrl;
  final FocusNode focus;

  const _SidebarSearch({required this.ctrl, required this.focus});

  @override
  State<_SidebarSearch> createState() => _SidebarSearchState();
}

class _SidebarSearchState extends State<_SidebarSearch> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(() {
      if (mounted) setState(() => _focused = widget.focus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 30,
        decoration: BoxDecoration(
          color: _focused ? Colors.white : _bodyBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _focused ? _blue.withOpacity(0.5) : _sidebarBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.search_rounded, size: 13, color: _textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: widget.ctrl,
                focusNode: widget.focus,
                style: const TextStyle(fontSize: 12, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  hintStyle: TextStyle(fontSize: 12, color: _textMuted),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffix: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _sidebarBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'Ctrl+K',
                      style: TextStyle(fontSize: 9, color: _textMuted),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String id;
  final String activeId;
  final VoidCallback onTap;
  final bool isChild;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.id,
    required this.activeId,
    required this.onTap,
    this.isChild = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.activeId == widget.id;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: EdgeInsets.symmetric(
            horizontal: widget.isChild ? 0 : 6,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: active
                ? _blue.withOpacity(0.1)
                : (_hovered ? _hoverBg : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: active
                ? Border(left: BorderSide(color: _activeItem, width: 2.5))
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.isChild ? 32 : (active ? 9.5 : 12),
              right: 12,
              top: 7,
              bottom: 7,
            ),
            child: Row(
              children: [
                if (!widget.isChild)
                  Icon(
                    widget.icon,
                    size: 15,
                    color: active ? _activeItem : _textMuted,
                  ),
                if (!widget.isChild) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? _activeItem : _textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarGroup extends StatefulWidget {
  final _MenuItem item;
  final bool expanded;
  final String activeId;
  final VoidCallback onToggle;
  final void Function(String) onNavigate;

  const _SidebarGroup({
    required this.item,
    required this.expanded,
    required this.activeId,
    required this.onToggle,
    required this.onNavigate,
  });

  @override
  State<_SidebarGroup> createState() => _SidebarGroupState();
}

class _SidebarGroupState extends State<_SidebarGroup>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;
  late final Animation<double> _chevronAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.expanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _chevronAnim = Tween<double>(begin: 0, end: 0.5).animate(_expandAnim);
  }

  @override
  void didUpdateWidget(_SidebarGroup old) {
    super.didUpdateWidget(old);
    if (widget.expanded != old.expanded) {
      widget.expanded ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Group header
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _hovered ? _hoverBg : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Icon(widget.item.icon!, size: 15, color: _textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _chevronAnim,
                      child: const Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Sub-items
        SizeTransition(
          sizeFactor: _expandAnim,
          axisAlignment: -1,
          child: Column(
            children: widget.item.children.map((child) {
              return Tooltip(
                message: child.tooltip ?? '',
                waitDuration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  color: _darkBlue.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                child: _SidebarItem(
                  icon: Icons.fiber_manual_record,
                  label: child.label,
                  id: child.id,
                  activeId: widget.activeId,
                  onTap: () => widget.onNavigate(child.id),
                  isChild: true,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'IA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Administrador',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              Text(
                'admin@ia.com',
                style: TextStyle(fontSize: 10, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Top bar
// ──────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String activeId;

  const _TopBar({required this.activeId});

  String get _breadcrumb {
    for (final item in _menu) {
      if (item.id == activeId) return item.label;
      for (final child in item.children) {
        if (child.id == activeId) return '${item.label} / ${child.label}';
      }
    }
    return activeId == 'notificacion' ? 'Notificación' : activeId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _sidebarBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Breadcrumb
          const Text(
            'Stock',
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
          const Icon(Icons.chevron_right_rounded, size: 16, color: _textMuted),
          Text(
            _breadcrumb,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const Spacer(),
          // Action buttons (contextual)
          _PrimaryButton(label: '+ Nuevo Registro', onTap: () {}),
          const SizedBox(width: 8),
          _HoverIcon(icon: Icons.filter_list_rounded, onTap: () {}),
          const SizedBox(width: 4),
          _HoverIcon(icon: Icons.refresh_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Content Area
// ──────────────────────────────────────────────

class _ContentArea extends StatelessWidget {
  final String activeId;

  const _ContentArea({required this.activeId});

  @override
  Widget build(BuildContext context) {
    if (activeId == 'dashboard') return const _DashboardContent();
    return _EmptyState(activeId: activeId);
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // KPI Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _KpiCard(
                label: 'Referencias activas',
                value: '663,092',
                icon: Icons.inventory_2_rounded,
                color: Color(0xFF458AC9),
              ),
              _KpiCard(
                label: 'Transacciones hoy',
                value: '0',
                icon: Icons.swap_horiz_rounded,
                color: Color(0xFF2BAE7E),
              ),
              _KpiCard(
                label: 'Recibos pendientes',
                value: '0',
                icon: Icons.receipt_rounded,
                color: Color(0xFFE67E22),
              ),
              _KpiCard(
                label: 'Inspecciones abiertas',
                value: '0',
                icon: Icons.fact_check_rounded,
                color: Color(0xFF7B5FF5),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Actividad Reciente',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _EmptyList(),
        ],
      ),
    );
  }
}

class _KpiCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 200,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered ? widget.color.withOpacity(0.4) : _sidebarBorder,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _hovered ? widget.color : _textPrimary,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _sidebarBorder),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: _textMuted),
            SizedBox(height: 10),
            Text(
              'No hay actividad reciente',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String activeId;

  const _EmptyState({required this.activeId});

  String get _label {
    for (final item in _menu) {
      if (item.id == activeId) return item.label;
      for (final child in item.children) {
        if (child.id == activeId) return child.label;
      }
    }
    return activeId;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 30,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No has creado ningún registro en "$_label" todavía',
            style: const TextStyle(fontSize: 13, color: _textMuted),
          ),
          const SizedBox(height: 16),
          _PrimaryButton(label: '+ Nuevo Registro', onTap: () {}),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Shared widgets
// ──────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF337AB7) : _blue,
            borderRadius: BorderRadius.circular(6),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _blue.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _HoverIcon({required this.icon, this.size = 18, required this.onTap});

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _hovered ? _bodyBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _hovered ? _darkBlue : _textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Keyboard intent ──────────────────────────
class _FocusSearchIntent extends Intent {}
