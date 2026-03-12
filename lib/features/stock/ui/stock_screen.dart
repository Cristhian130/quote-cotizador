import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _blue = Color(0xFF458AC9);
const Color _darkBlue = Color(0xFF192D4D);
const Color _sidebarBg = Color(0xFFFFFFFF);
const Color _sidebarBorder = Color(0xFFE2E4E9);
const Color _bodyBg = Color(0xFFF4F5F7);
const Color _textMuted = Color(0xFF8A94A6);
const Color _textPrimary = Color(0xFF1C2333);
const Color _activeItem = Color(0xFF458AC9);
const Color _hoverBg = Color(0xFFF0F4F9);

// Menu item models

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

//  Data

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

//  Stock Screen

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
              // Left Sidebar
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
              // Main Content
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

//  Sidebar

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

//  Top bar (context-aware per section)

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
    // The list-view pages get a different toolbar
    final isListView =
        activeId == 'transaccion' ||
        activeId == 'recibo' ||
        activeId == 'salida' ||
        activeId == 'solicitud';

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _sidebarBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Breadcrumb
          Text(
            'Stock',
            style: const TextStyle(fontSize: 12.5, color: _textMuted),
          ),
          const Icon(Icons.chevron_right_rounded, size: 15, color: _textMuted),
          Text(
            _breadcrumb,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const Spacer(),
          if (isListView) ..._listToolbar(activeId) else ..._defaultToolbar(),
        ],
      ),
    );
  }

  List<Widget> _listToolbar(String id) {
    final label = id == 'transaccion'
        ? 'Transacción de Stock'
        : id == 'recibo'
        ? 'Recibo de Compra'
        : id == 'salida'
        ? 'Salida por Venta'
        : 'Solicitar Referencia';
    return [
      _DropdownChip(label: 'Vista de Lista', icon: Icons.view_list_rounded),
      const SizedBox(width: 8),
      _DropdownChip(label: 'Filtros guardados', icon: null),
      const SizedBox(width: 8),
      _HoverIcon(icon: Icons.refresh_rounded, onTap: () {}),
      const SizedBox(width: 4),
      _HoverIcon(icon: Icons.more_horiz_rounded, onTap: () {}),
      const SizedBox(width: 8),
      _PrimaryButton(label: '+ Agregar $label', onTap: () {}),
    ];
  }

  List<Widget> _defaultToolbar() {
    return [
      _PrimaryButton(label: '+ Nuevo Registro', onTap: () {}),
      const SizedBox(width: 8),
      _HoverIcon(icon: Icons.filter_list_rounded, onTap: () {}),
      const SizedBox(width: 4),
      _HoverIcon(icon: Icons.refresh_rounded, onTap: () {}),
    ];
  }
}

//  Content Area

class _ContentArea extends StatelessWidget {
  final String activeId;

  const _ContentArea({required this.activeId});

  @override
  Widget build(BuildContext context) {
    switch (activeId) {
      case 'dashboard':
        return const _DashboardContent();
      case 'transaccion':
        return const _TransaccionListView();
      case 'recibo':
        return const _ReciboListView();
      default:
        return _EmptyState(activeId: activeId);
    }
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

//  Shared widgets

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

//  Dropdown chip (List View / Saved Filters)

class _DropdownChip extends StatefulWidget {
  final String label;
  final IconData? icon;

  const _DropdownChip({required this.label, this.icon});

  @override
  State<_DropdownChip> createState() => _DropdownChipState();
}

class _DropdownChipState extends State<_DropdownChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _hovered ? _bodyBg : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: _sidebarBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 13, color: _textMuted),
              const SizedBox(width: 5),
            ],
            Text(
              widget.label,
              style: const TextStyle(fontSize: 12, color: _textPrimary),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: _textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

//  Transacción de Stock - ERPNext list view

class _TransaccionListView extends StatefulWidget {
  const _TransaccionListView();

  @override
  State<_TransaccionListView> createState() => _TransaccionListViewState();
}

class _TransaccionListViewState extends State<_TransaccionListView>
    with SingleTickerProviderStateMixin {
  bool _filterVisible = true;
  bool _showingForm = false;

  late final AnimationController _formCtrl;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  static const _cols = [
    _ColDef(id: 'id', label: 'ID', flex: 2),
    _ColDef(id: 'tipo', label: 'Tipo de Transacción', flex: 3),
    _ColDef(id: 'origen', label: 'Bodega de Origen Pred.', flex: 3),
    _ColDef(id: 'destino', label: 'Bodega de Destino Pred.', flex: 3),
  ];

  @override
  void initState() {
    super.initState();
    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  void _openForm() {
    setState(() => _showingForm = true);
    _formCtrl.forward(from: 0);
  }

  void _closeForm() {
    _formCtrl.reverse().then((_) {
      if (mounted) setState(() => _showingForm = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingForm) {
      return FadeTransition(
        opacity: _formFade,
        child: SlideTransition(
          position: _formSlide,
          child: _NuevaTransaccionForm(onBack: _closeForm),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter bar
        _FilterBar(
          visible: _filterVisible,
          onToggle: () => setState(() => _filterVisible = !_filterVisible),
        ),

        // Column header row
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _sidebarBorder)),
          ),
          child: Row(
            children: [
              // Checkbox column
              const SizedBox(
                width: 44,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: _ColumnCheckbox(),
                ),
              ),
              // Data columns
              ..._cols.map(
                (col) => Expanded(
                  flex: col.flex,
                  child: _ColHeader(col: col),
                ),
              ),
            ],
          ),
        ),

        // Empty state
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Document icon (like ERPNext)
                  const Icon(
                    Icons.description_outlined,
                    size: 52,
                    color: Color(0xFFCDD2DA),
                  ),
                  const SizedBox(height: 18),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13.5, color: _textMuted),
                      children: [
                        TextSpan(text: 'No has '),
                        TextSpan(
                          text: 'creado',
                          style: TextStyle(
                            color: _blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(text: ' una Transacción de Stock todavía'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LinkButton(
                    label: 'Crear tu primera Transacción de Stock',
                    onTap: _openForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Filter bar (with filter chip + sort)
class _FilterBar extends StatefulWidget {
  final bool visible;
  final VoidCallback onToggle;

  const _FilterBar({required this.visible, required this.onToggle});

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  bool _filterHover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _sidebarBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Filter toggle
          MouseRegion(
            onEnter: (_) => setState(() => _filterHover = true),
            onExit: (_) => setState(() => _filterHover = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _filterHover ? _bodyBg : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _sidebarBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 13,
                      color: _textMuted,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Filtrar',
                      style: TextStyle(fontSize: 12, color: _textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Clear button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _bodyBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: _textMuted,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Sort - Created On
          Row(
            children: [
              const Icon(Icons.sort_rounded, size: 14, color: _textMuted),
              const SizedBox(width: 5),
              const Text(
                'Creado el',
                style: TextStyle(fontSize: 12, color: _textPrimary),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: _textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Column header
class _ColHeader extends StatefulWidget {
  final _ColDef col;

  const _ColHeader({required this.col});

  @override
  State<_ColHeader> createState() => _ColHeaderState();
}

class _ColHeaderState extends State<_ColHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _hovered ? _bodyBg : const Color(0xFFF8F9FA),
          border: const Border(
            right: BorderSide(color: _sidebarBorder, width: 0.7),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.col.label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                  letterSpacing: 0.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_hovered)
              const Icon(
                Icons.unfold_more_rounded,
                size: 13,
                color: _textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

// Checkbox header
class _ColumnCheckbox extends StatefulWidget {
  const _ColumnCheckbox();

  @override
  State<_ColumnCheckbox> createState() => _ColumnCheckboxState();
}

class _ColumnCheckboxState extends State<_ColumnCheckbox> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _checked = !_checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: _checked ? _blue : Colors.white,
          border: Border.all(
            color: _checked ? _blue : _sidebarBorder,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: _checked
            ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
            : null,
      ),
    );
  }
}

// Link-style button (like "Create your first Stock Entry")
class _LinkButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _LinkButton({required this.label, required this.onTap});

  @override
  State<_LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<_LinkButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? _bodyBg : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _blue.withOpacity(0.5)),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.5,
              color: _hovered ? const Color(0xFF2B74AE) : _blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Col definition
class _ColDef {
  final String id;
  final String label;
  final int flex;

  const _ColDef({required this.id, required this.label, required this.flex});
}

//  Nueva Transacción de Stock

class _NuevaTransaccionForm extends StatefulWidget {
  final VoidCallback onBack;

  const _NuevaTransaccionForm({required this.onBack});

  @override
  State<_NuevaTransaccionForm> createState() => _NuevaTransaccionFormState();
}

class _NuevaTransaccionFormState extends State<_NuevaTransaccionForm>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // Field state
  String _serie = 'MAT-STE-.YYYY.-';
  String _tipoTransaccion = '';
  bool _editarFechaHora = false;
  String _fechaPublicacion = '11-03-2026';
  String _horaPublicacion = '11:40:00';
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bodyBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form top bar
          _FormTopBar(
            onBack: widget.onBack,
            isSaved: _isSaved,
            onSave: () => setState(() => _isSaved = true),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: false,
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
              indicatorColor: _blue,
              indicatorWeight: 2,
              labelColor: _blue,
              unselectedLabelColor: _textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Detalles'),
                Tab(text: 'Dimensiones Contables'),
                Tab(text: 'Otra Información'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _DetallesTab(
                  serie: _serie,
                  onSerieChanged: (v) => setState(() => _serie = v),
                  tipoTransaccion: _tipoTransaccion,
                  onTipoChanged: (v) => setState(() => _tipoTransaccion = v),
                  editarFechaHora: _editarFechaHora,
                  onEditarFechaHoraChanged: (v) =>
                      setState(() => _editarFechaHora = v),
                  fechaPublicacion: _fechaPublicacion,
                  horaPublicacion: _horaPublicacion,
                ),
                const _DimensionesTab(),
                const _OtraInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  Form top bar
class _FormTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool isSaved;
  final VoidCallback onSave;

  const _FormTopBar({
    required this.onBack,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back / breadcrumb
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onBack,
              child: const Icon(
                Icons.description_outlined,
                size: 16,
                color: _textMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onBack,
            child: const Text(
              'Stock',
              style: TextStyle(fontSize: 12.5, color: _textMuted),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 14, color: _textMuted),
          GestureDetector(
            onTap: onBack,
            child: const Text(
              'Transacción de Stock',
              style: TextStyle(fontSize: 12.5, color: _textMuted),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 14, color: _textMuted),
          const Text(
            'Nueva Transacción de Stock',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isSaved
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isSaved ? 'Guardado' : 'No Guardado',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSaved
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE67E22),
              ),
            ),
          ),
          const Spacer(),
          // Action buttons
          _DropdownChip(label: 'Crear', icon: null),
          const SizedBox(width: 8),
          _DropdownChip(label: 'Obtener artículos de', icon: null),
          const SizedBox(width: 8),
          // Save button (black)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSave,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _textPrimary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  Detalles tab
class _DetallesTab extends StatefulWidget {
  final String serie;
  final ValueChanged<String> onSerieChanged;
  final String tipoTransaccion;
  final ValueChanged<String> onTipoChanged;
  final bool editarFechaHora;
  final ValueChanged<bool> onEditarFechaHoraChanged;
  final String fechaPublicacion;
  final String horaPublicacion;

  const _DetallesTab({
    required this.serie,
    required this.onSerieChanged,
    required this.tipoTransaccion,
    required this.onTipoChanged,
    required this.editarFechaHora,
    required this.onEditarFechaHoraChanged,
    required this.fechaPublicacion,
    required this.horaPublicacion,
  });

  @override
  State<_DetallesTab> createState() => _DetallesTabState();
}

class _DetallesTabState extends State<_DetallesTab> {
  final List<_StockItem> _items = [_StockItem(id: 1)];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _sidebarBorder),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Serie + date/time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Serie + Tipo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FormField(
                                  label: 'Serie',
                                  required: true,
                                  child: _DropdownField(
                                    value: widget.serie,
                                    items: const [
                                      'MAT-STE-.YYYY.-',
                                      'STE-.YYYY.-',
                                    ],
                                    onChanged: widget.onSerieChanged,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _FormField(
                                  label: 'Tipo de Transacción de Stock',
                                  required: true,
                                  child: _DropdownField(
                                    value: widget.tipoTransaccion.isEmpty
                                        ? null
                                        : widget.tipoTransaccion,
                                    hint: 'Seleccionar tipo',
                                    items: const [
                                      'Transferencia de material',
                                      'Recibo de material',
                                      'Emisión de material',
                                      'Fabricar',
                                      'Repack',
                                      'Enviar a subcontrato',
                                      'Recibir en subcontrato',
                                    ],
                                    onChanged: widget.onTipoChanged,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          // Right: Date + Time
                          SizedBox(
                            width: 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _AnimatedCheckbox(
                                      value: widget.editarFechaHora,
                                      onChanged:
                                          widget.onEditarFechaHoraChanged,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Editar Fecha y Hora de Publicación',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _FormField(
                                  label: 'Fecha de Publicación',
                                  child: _ReadOnlyField(
                                    value: widget.fechaPublicacion,
                                    editable: widget.editarFechaHora,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _FormField(
                                  label: 'Hora de Publicación',
                                  child: _ReadOnlyField(
                                    value: widget.horaPublicacion,
                                    editable: widget.editarFechaHora,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: _sidebarBorder),
                      const SizedBox(height: 12),

                      // BOM Info & Default Warehouse - collapsible sections
                      _InlineAccordion(
                        title: 'Información BOM',
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 4),
                          child: _CheckboxRow(label: 'Desde BOM'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InlineAccordion(
                        title: 'Bodega Predeterminada',
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 4),
                          child: _FormField(
                            label: 'Bodega de Origen Predeterminada',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                _TextInputField(hint: ''),
                                SizedBox(height: 4),
                                Text(
                                  "Establece la 'Bodega de Origen' en cada fila de la tabla de artículos.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scan barcode
                      _FormField(
                        label: 'Escanear Código de Barras',
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(color: _sidebarBorder),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const TextField(
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 9,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                border: Border.all(color: _sidebarBorder),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 18,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Items table
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _sidebarBorder),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Text(
                          'Artículos',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: _sidebarBorder),

                      // Table header
                      Container(
                        color: const Color(0xFFF8F9FA),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 40,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: _ColumnCheckbox(),
                              ),
                            ),
                            SizedBox(width: 36, child: _TableHeader('No.')),
                            Expanded(
                              flex: 2,
                              child: _TableHeader('Bodega Origen'),
                            ),
                            Expanded(
                              flex: 3,
                              child: _TableHeader('Código de Artículo *'),
                            ),
                            Expanded(flex: 2, child: _TableHeader('Cant. *')),
                            Expanded(
                              flex: 2,
                              child: _TableHeader('Tarifa Base (según...'),
                            ),
                            SizedBox(width: 36),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: _sidebarBorder),

                      // Item rows
                      ..._items.asMap().entries.map(
                        (e) => _ItemRow(
                          item: e.value,
                          onDelete: () =>
                              setState(() => _items.removeAt(e.key)),
                        ),
                      ),

                      const Divider(height: 1, color: _sidebarBorder),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _items.add(
                                    _StockItem(id: _items.length + 1),
                                  ),
                                ),
                                child: const Text(
                                  'Agregar fila',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Descargar',
                              style: TextStyle(fontSize: 12, color: _textMuted),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Cargar',
                              style: TextStyle(fontSize: 12, color: _textMuted),
                            ),
                          ],
                        ),
                      ),

                      // Update rates link
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12.5, color: _textMuted),
                            children: [
                              TextSpan(
                                text: 'Actualizar',
                                style: TextStyle(color: _blue),
                              ),
                              TextSpan(text: ' Tarifa y '),
                              TextSpan(
                                text: 'Disponibilidad',
                                style: TextStyle(color: _blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Table header cell
class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: _textMuted,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Individual item row
class _StockItem {
  final int id;
  String bodegaOrigen = '';
  String codigo = '';
  double cantidad = 0.0;
  double tarifa = 0.0;

  _StockItem({required this.id});
}

class _ItemRow extends StatelessWidget {
  final _StockItem item;
  final VoidCallback onDelete;

  const _ItemRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _sidebarBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 40,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: _ColumnCheckbox(),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${item.id}',
              style: const TextStyle(fontSize: 12, color: _textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(flex: 2, child: _InlineField(hint: '')),
          Expanded(flex: 3, child: _InlineField(hint: '')),
          Expanded(
            flex: 2,
            child: _InlineField(hint: '0.000', align: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                '\$ 0.00',
                style: const TextStyle(fontSize: 12.5, color: _textPrimary),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: IconButton(
              icon: const Icon(
                Icons.edit_note_rounded,
                size: 15,
                color: _textMuted,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }
}

// Inline table field
class _InlineField extends StatelessWidget {
  final String hint;
  final TextAlign align;

  const _InlineField({required this.hint, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        textAlign: align,
        style: const TextStyle(fontSize: 12.5, color: _textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 9,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

//  Dimensiones Contables tab
class _DimensionesTab extends StatelessWidget {
  const _DimensionesTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _sidebarBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(24),
                child: _FormField(
                  label: 'Proyecto',
                  child: _TextInputField(hint: 'Seleccionar proyecto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  Otra Información tab
class _OtraInfoTab extends StatelessWidget {
  const _OtraInfoTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                // Printing Settings
                _CollapsibleSection(
                  title: 'Configuración de Impresión',
                  child: Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Encabezado de Impresión',
                          child: _TextInputField(hint: ''),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _FormField(
                          label: 'Membrete',
                          child: _ReadOnlyField(
                            value: 'Membrete de Empresa - Gris',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // More information
                _CollapsibleSection(
                  title: 'Más Información',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 260,
                        child: _FormField(
                          label: 'Es Apertura',
                          child: _DropdownField(
                            value: 'No',
                            items: const ['No', 'Sí'],
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FormField(
                        label: 'Observaciones',
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: _sidebarBorder),
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xFFF8F9FA),
                          ),
                          child: const TextField(
                            maxLines: null,
                            expands: true,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _textPrimary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              isDense: true,
                            ),
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
      ),
    );
  }
}

// Shared form widgets

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;

  const _CollapsibleSection({required this.title, required this.child});

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _sidebarBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _expanded = !_expanded);
              _expanded ? _ctrl.forward() : _ctrl.reverse();
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: -0.5).animate(_anim),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _anim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;

  const _FormField({
    required this.label,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(fontSize: 11.5, color: Color(0xFFE53935)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _ExpandableLink extends StatefulWidget {
  final String label;

  const _ExpandableLink({required this.label});

  @override
  State<_ExpandableLink> createState() => _ExpandableLinkState();
}

class _ExpandableLinkState extends State<_ExpandableLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _hovered ? const Color(0xFF2B74AE) : _textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: _hovered ? _blue : _textMuted,
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String? hint;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    this.value,
    this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: _sidebarBorder),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value != null && items.contains(value) ? value : null,
          hint: Text(
            hint ?? '',
            style: const TextStyle(fontSize: 12.5, color: _textMuted),
          ),
          isExpanded: true,
          style: const TextStyle(fontSize: 12.5, color: _textPrimary),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: _textMuted,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12.5)),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  final String hint;

  const _TextInputField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: _sidebarBorder),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        style: const TextStyle(fontSize: 12.5, color: _textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textMuted, fontSize: 12.5),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 9,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final bool editable;

  const _ReadOnlyField({required this.value, this.editable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _sidebarBorder),
        borderRadius: BorderRadius.circular(5),
        color: editable ? Colors.white : const Color(0xFFF4F5F7),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12.5,
          color: editable ? _textPrimary : _textMuted,
        ),
      ),
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: value ? _blue : Colors.white,
            border: Border.all(
              color: value ? _blue : _sidebarBorder,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: value
              ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

//  Inline Accordion - collapsible section (BOM / Warehouse style)

class _InlineAccordion extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _InlineAccordion({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_InlineAccordion> createState() => _InlineAccordionState();
}

class _InlineAccordionState extends State<_InlineAccordion>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _expanded ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        GestureDetector(
          onTap: () {
            setState(() => _expanded = !_expanded);
            _expanded ? _ctrl.forward() : _ctrl.reverse();
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5).animate(_anim),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated content
        SizeTransition(
          sizeFactor: _anim,
          axisAlignment: -1,
          child: widget.child,
        ),
        const SizedBox(height: 4),
        const Divider(color: _sidebarBorder, height: 1),
      ],
    );
  }
}

//  Checkbox row (label beside a bordered checkbox)

class _CheckboxRow extends StatefulWidget {
  final String label;

  const _CheckboxRow({required this.label});

  @override
  State<_CheckboxRow> createState() => _CheckboxRowState();
}

class _CheckboxRowState extends State<_CheckboxRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _checked = !_checked),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: _checked ? _blue : Colors.white,
                border: Border.all(
                  color: _checked ? _blue : _sidebarBorder,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: _checked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 10,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 12.5, color: _textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// Keyboard intent
class _FocusSearchIntent extends Intent {}

//  Recibo de Compra - ERPNext list view

class _ReciboListView extends StatefulWidget {
  const _ReciboListView();

  @override
  State<_ReciboListView> createState() => _ReciboListViewState();
}

class _ReciboListViewState extends State<_ReciboListView>
    with SingleTickerProviderStateMixin {
  bool _showingForm = false;
  late final AnimationController _formCtrl;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  static const _cols = [
    _ColDef(id: 'id', label: 'ID', flex: 2),
    _ColDef(id: 'titulo', label: 'Título', flex: 3),
    _ColDef(id: 'empresa', label: 'Empresa', flex: 3),
    _ColDef(id: 'estado', label: 'Estado', flex: 2),
  ];

  @override
  void initState() {
    super.initState();
    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  void _openForm() {
    setState(() => _showingForm = true);
    _formCtrl.forward(from: 0);
  }

  void _closeForm() {
    _formCtrl.reverse().then((_) {
      if (mounted) setState(() => _showingForm = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingForm) {
      return FadeTransition(
        opacity: _formFade,
        child: SlideTransition(
          position: _formSlide,
          child: _ReciboFormView(onBack: _closeForm),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter bar
        _ReciboFilterBar(),

        // Column headers
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _sidebarBorder)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 44,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: _ColumnCheckbox(),
                ),
              ),
              ..._cols.map(
                (col) => Expanded(
                  flex: col.flex,
                  child: _ReciboColHeader(col: col),
                ),
              ),
            ],
          ),
        ),

        // Empty state
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 52,
                    color: Color(0xFFCDD2DA),
                  ),
                  const SizedBox(height: 18),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13.5, color: _textMuted),
                      children: [
                        TextSpan(text: 'No has '),
                        TextSpan(
                          text: 'creado',
                          style: TextStyle(
                            color: _blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(text: ' un Recibo de Compra todavía'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LinkButton(
                    label: 'Crear tu primer Recibo de Compra',
                    onTap: _openForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Filter bar
class _ReciboFilterBar extends StatefulWidget {
  @override
  State<_ReciboFilterBar> createState() => _ReciboFilterBarState();
}

class _ReciboFilterBarState extends State<_ReciboFilterBar> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _sidebarBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _hover ? _bodyBg : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: _sidebarBorder),
              ),
              child: Row(
                children: const [
                  Icon(Icons.filter_list_rounded, size: 13, color: _textMuted),
                  SizedBox(width: 5),
                  Text(
                    'Filtrar',
                    style: TextStyle(fontSize: 12, color: _textPrimary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: _bodyBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 12, color: _textMuted),
          ),
          const Spacer(),
          Row(
            children: const [
              Icon(Icons.sort_rounded, size: 14, color: _textMuted),
              SizedBox(width: 5),
              Text(
                'Creado el',
                style: TextStyle(fontSize: 12, color: _textPrimary),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: _textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Column header
class _ReciboColHeader extends StatefulWidget {
  final _ColDef col;
  const _ReciboColHeader({required this.col});

  @override
  State<_ReciboColHeader> createState() => _ReciboColHeaderState();
}

class _ReciboColHeaderState extends State<_ReciboColHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _hovered ? _bodyBg : const Color(0xFFF8F9FA),
          border: const Border(
            right: BorderSide(color: _sidebarBorder, width: 0.7),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.col.label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.col.id == 'estado' || _hovered)
              Icon(
                widget.col.id == 'estado'
                    ? Icons.swap_vert_rounded
                    : Icons.unfold_more_rounded,
                size: 13,
                color: _textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

//  Recibo de Compra - New form view

class _ReciboFormView extends StatefulWidget {
  final VoidCallback onBack;
  const _ReciboFormView({required this.onBack});

  @override
  State<_ReciboFormView> createState() => _ReciboFormViewState();
}

class _ReciboFormViewState extends State<_ReciboFormView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  bool _isSaved = false;
  String _serie = 'MAT-PRE-.YYYY.-';
  bool _editarFechaHora = false;
  bool _aplicarPutaway = false;
  bool _esDev = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: _sidebarBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_outlined, size: 15, color: _textMuted),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.onBack,
                  child: const Text(
                    'Stock',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: _textMuted,
                ),
                GestureDetector(
                  onTap: widget.onBack,
                  child: const Text(
                    'Recibo de Compra',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: _textMuted,
                ),
                const Text(
                  'Nuevo Recibo de Compra',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _isSaved
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _isSaved ? 'Guardado' : 'No Guardado',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _isSaved
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE67E22),
                    ),
                  ),
                ),
                const Spacer(),
                // Get Items From -
                _DropdownChip(label: 'Obtener artículos de', icon: null),
                const SizedBox(width: 8),
                // Save
                GestureDetector(
                  onTap: () => setState(() => _isSaved = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _textPrimary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: _blue,
              indicatorWeight: 2,
              labelColor: _blue,
              unselectedLabelColor: _textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              tabs: const [
                Tab(text: 'Detalles'),
                Tab(text: 'Dirección y Contacto'),
                Tab(text: 'Términos'),
                Tab(text: 'Más Información'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _ReciboDetallesTab(
                  serie: _serie,
                  onSerieChanged: (v) => setState(() => _serie = v),
                  editarFechaHora: _editarFechaHora,
                  onEditarFechaHoraChanged: (v) =>
                      setState(() => _editarFechaHora = v),
                  aplicarPutaway: _aplicarPutaway,
                  onAplicarPutawayChanged: (v) =>
                      setState(() => _aplicarPutaway = v),
                  esDev: _esDev,
                  onEsDevChanged: (v) => setState(() => _esDev = v),
                ),
                const _RcDireccionTab(),
                const _RcTerminosTab(),
                const _RcMasInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReciboDetallesTab extends StatefulWidget {
  final String serie;
  final ValueChanged<String> onSerieChanged;
  final bool editarFechaHora;
  final ValueChanged<bool> onEditarFechaHoraChanged;
  final bool aplicarPutaway;
  final ValueChanged<bool> onAplicarPutawayChanged;
  final bool esDev;
  final ValueChanged<bool> onEsDevChanged;

  const _ReciboDetallesTab({
    required this.serie,
    required this.onSerieChanged,
    required this.editarFechaHora,
    required this.onEditarFechaHoraChanged,
    required this.aplicarPutaway,
    required this.onAplicarPutawayChanged,
    required this.esDev,
    required this.onEsDevChanged,
  });

  @override
  State<_ReciboDetallesTab> createState() => _ReciboDetallesTabState();
}

class _ReciboDetallesTabState extends State<_ReciboDetallesTab> {
  final List<_StockItem> _items = [_StockItem(id: 1)];
  bool _ignorarRegla = false;
  bool _desHabRed = false;
  bool _esSubcontrato = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Serie / Date+checkboxes
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FormField(
                                    label: 'Serie',
                                    required: true,
                                    child: _DropdownField(
                                      value: widget.serie,
                                      items: const [
                                        'MAT-PRE-.YYYY.-',
                                        'PRE-.YYYY.-',
                                      ],
                                      onChanged: widget.onSerieChanged,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _FormField(
                                    label: 'Proveedor',
                                    required: true,
                                    child: const _TextInputField(hint: ''),
                                  ),
                                  const SizedBox(height: 14),
                                  _FormField(
                                    label: 'Nota de Entrega del Proveedor',
                                    child: const _TextInputField(hint: ''),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right column
                            SizedBox(
                              width: 280,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Checkboxes row
                                  _CheckboxRow(label: 'Aplicar Regla Putaway'),
                                  const SizedBox(height: 8),
                                  _CheckboxRow(label: 'Es Devolución'),
                                  const SizedBox(height: 14),
                                  _FormField(
                                    label: 'Fecha',
                                    required: true,
                                    child: _ReadOnlyField(
                                      value: '11-03-2026',
                                      editable: widget.editarFechaHora,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _FormField(
                                    label: 'Hora de Publicación',
                                    required: true,
                                    child: _ReadOnlyField(
                                      value: '12:21:07',
                                      editable: widget.editarFechaHora,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () =>
                                        widget.onEditarFechaHoraChanged(
                                          !widget.editarFechaHora,
                                        ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 140,
                                          ),
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: widget.editarFechaHora
                                                ? _blue
                                                : Colors.white,
                                            border: Border.all(
                                              color: widget.editarFechaHora
                                                  ? _blue
                                                  : _sidebarBorder,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                          child: widget.editarFechaHora
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 10,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 7),
                                        const Text(
                                          'Editar Fecha y Hora de Publicación',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // -”€ Dimensiones Contables -
                        _InlineAccordion(
                          title: 'Dimensiones Contables',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _FormField(
                                    label: 'Centro de Costos',
                                    child: const _TextInputField(hint: ''),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _FormField(
                                    label: 'Proyecto',
                                    child: const _TextInputField(hint: ''),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // -”€ Moneda y Lista de Precios -
                        _InlineAccordion(
                          title: 'Moneda y Lista de Precios',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1
                                Row(
                                  children: [
                                    Expanded(
                                      child: _FormField(
                                        label: 'Moneda',
                                        required: true,
                                        child: _DropdownField(
                                          value: 'COP',
                                          items: const ['COP', 'USD', 'EUR'],
                                          onChanged: (_) {},
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _FormField(
                                        label: 'Lista de Precios',
                                        child: const _ReadOnlyField(
                                          value: 'Standard Buying',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Row 2
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _FormField(
                                            label: 'Tasa de Cambio',
                                            required: true,
                                            child: const _ReadOnlyField(
                                              value: '1,000000000',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Tasa a la que la moneda del proveedor se convierte a la moneda base de la empresa',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: _blue,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _FormField(
                                            label: 'Moneda de Lista de Precios',
                                            child: const _ReadOnlyField(
                                              value: 'COP',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          _FormField(
                                            label:
                                                'Tasa de Cambio de Lista de Precios',
                                            child: const _ReadOnlyField(
                                              value: '1,000000000',
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () => setState(
                                              () => _ignorarRegla =
                                                  !_ignorarRegla,
                                            ),
                                            child: Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 140,
                                                  ),
                                                  width: 14,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color: _ignorarRegla
                                                        ? _blue
                                                        : Colors.white,
                                                    border: Border.all(
                                                      color: _ignorarRegla
                                                          ? _blue
                                                          : _sidebarBorder,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                  child: _ignorarRegla
                                                      ? const Icon(
                                                          Icons.check_rounded,
                                                          size: 10,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 7),
                                                const Text(
                                                  'Ignorar Regla de Precios',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),
                  _RcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        _RcSectionHeader(label: 'Artículos'),
                        const SizedBox(height: 14),

                        // Barcode / Warehouses row
                        Row(
                          children: [
                            Expanded(
                              child: _FormField(
                                label: 'Escanear Código de Barras',
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _sidebarBorder,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const TextField(
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: _textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 7,
                                                ),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _sidebarBorder,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 16,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _FormField(
                                label: 'Bodega de Aceptación',
                                child: const _TextInputField(hint: ''),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _FormField(
                                label: 'Bodega de Rechazo',
                                child: const _TextInputField(hint: ''),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _esSubcontrato = !_esSubcontrato),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: _esSubcontrato ? _blue : Colors.white,
                                  border: Border.all(
                                    color: _esSubcontrato
                                        ? _blue
                                        : _sidebarBorder,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: _esSubcontrato
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 10,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 7),
                              const Text(
                                'Es Subcontratado',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Items table
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: _sidebarBorder),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                color: const Color(0xFFF8F9FA),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 36,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: _ColumnCheckbox(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                      child: _TableHeader('No.'),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: _TableHeader(
                                        'Código de Artículo *',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Cant. Aceptada'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Rechazada'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Tarifa'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Monto'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Bodega Acept.'),
                                    ),
                                    SizedBox(width: 30),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: _sidebarBorder),
                              ..._items.asMap().entries.map(
                                (e) => _RcItemRow(
                                  item: e.value,
                                  onDelete: () =>
                                      setState(() => _items.removeAt(e.key)),
                                ),
                              ),
                              const Divider(height: 1, color: _sidebarBorder),
                              // Footer
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    _RcLinkBtn(
                                      label: 'Agregar fila',
                                      onTap: () => setState(
                                        () => _items.add(
                                          _StockItem(id: _items.length + 1),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _RcLinkBtn(
                                      label: 'Agregar múltiples',
                                      onTap: () {},
                                    ),
                                    const Spacer(),
                                    const Text(
                                      'Descargar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Cargar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Totals grid (3 columns)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Col 1
                            Expanded(
                              child: _FormField(
                                label: 'Cantidad Total',
                                child: const _ReadOnlyField(value: '0'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Col 2
                            Expanded(
                              child: Column(
                                children: [
                                  _FormField(
                                    label: 'Total (Moneda de Empresa)',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    label: 'Neto Total (Moneda de Empresa)',
                                    required: true,
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Col 3
                            Expanded(
                              child: Column(
                                children: [
                                  _FormField(
                                    label: 'Total',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    label: 'Neto Total',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),
                  _RcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RcSectionHeader(label: 'Impuestos y Cargos'),
                        const SizedBox(height: 14),
                        // Tax fields
                        Row(
                          children: [
                            Expanded(
                              child: _FormField(
                                label: 'Categoría de Impuesto',
                                child: const _TextInputField(hint: ''),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _FormField(
                                label: 'Regla de Envío',
                                child: const _TextInputField(hint: ''),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _FormField(
                                label: 'Incoterm',
                                child: const _TextInputField(hint: ''),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 320,
                          child: _FormField(
                            label: 'Plantilla de Impuestos y Cargos de Compra',
                            child: const _TextInputField(hint: ''),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tax table
                        const Text(
                          'Impuestos y Cargos de Compra',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: _sidebarBorder),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: [
                              Container(
                                color: const Color(0xFFF8F9FA),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 36,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: _ColumnCheckbox(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
                                      child: _TableHeader('No.'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Tipo *'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Cuenta Principal *'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Tasa Impuesto'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Monto Neto'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Monto'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('Total'),
                                    ),
                                    SizedBox(width: 30),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: _sidebarBorder),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Sin filas',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _textMuted,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1, color: _sidebarBorder),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: _RcLinkBtn(
                                  label: 'Agregar fila',
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tax totals 2-column grid
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _FormField(
                                    label:
                                        'Impuestos y Cargos Agregados (Moneda Empresa)',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    label:
                                        'Impuestos y Cargos Deducidos (Moneda Empresa)',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    label:
                                        'Total Impuestos y Cargos (Moneda Empresa)',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _FormField(
                                    label: 'Impuestos y Cargos Agregados',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    label: 'Impuestos y Cargos Deducidos',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    label: 'Total Impuestos y Cargos',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // -Card 4: Totales (COP)
                  const SizedBox(height: 1),
                  _RcCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RcSectionHeader(label: 'Totales (COP)'),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _FormField(
                                label: 'Total General',
                                child: const _ReadOnlyField(value: r'$ 0,00'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Disable rounded total checkbox
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _desHabRed = !_desHabRed,
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 140,
                                          ),
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: _desHabRed
                                                ? _blue
                                                : Colors.white,
                                            border: Border.all(
                                              color: _desHabRed
                                                  ? _blue
                                                  : _sidebarBorder,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                          child: _desHabRed
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 10,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 7),
                                        const Text(
                                          'Deshabilitar Total Redondeado',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _FormField(
                                    label: 'Ajuste de Redondeo',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    label: 'Total Redondeado',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Card 5: Descuento Adicional
                  const SizedBox(height: 1),
                  _RcCard(
                    child: _InlineAccordion(
                      title: 'Descuento Adicional',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _FormField(
                                    label: 'Aplicar Descuento Adicional En',
                                    child: _DropdownField(
                                      value: 'Total General',
                                      items: const [
                                        'Total General',
                                        'Neto Total',
                                      ],
                                      onChanged: (_) {},
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _FormField(
                                    label: 'Porcentaje de Descuento Adicional',
                                    child: const _TextInputField(hint: ''),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _FormField(
                                    label:
                                        'Monto de Descuento Adicional (Moneda Empresa)',
                                    child: const _ReadOnlyField(
                                      value: r'$ 0,00',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _FormField(
                                    label: 'Monto de Descuento Adicional',
                                    child: const _TextInputField(hint: ''),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // -Card 6: Materias Primas
                  const SizedBox(height: 1),
                  _RcCard(
                    child: _InlineAccordion(
                      title: 'Materias Primas Consumidas',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Artículos Consumidos',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: _sidebarBorder),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    color: const Color(0xFFF8F9FA),
                                    child: Row(
                                      children: const [
                                        SizedBox(
                                          width: 36,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: _ColumnCheckbox(),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: _TableHeader('No.'),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _TableHeader(
                                            'Código de Artículo',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _TableHeader(
                                            'Artículo Mat. Prima',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _TableHeader(
                                            'Cant. Disponible',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _TableHeader(
                                            'Cant. a Consumir',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _TableHeader('Stock Actual'),
                                        ),
                                        SizedBox(width: 30),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: _sidebarBorder,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'Sin filas',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: _textMuted,
                                        ),
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
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// White card wrapper (ERPNext section style)
class _RcCard extends StatelessWidget {
  final Widget child;
  const _RcCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: child,
    );
  }
}

// Section header (bold label + thin bottom border)
class _RcSectionHeader extends StatelessWidget {
  final String label;
  const _RcSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: _sidebarBorder, height: 1),
      ],
    );
  }
}

// Small blue link button
class _RcLinkBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _RcLinkBtn({required this.label, required this.onTap});

  @override
  State<_RcLinkBtn> createState() => _RcLinkBtnState();
}

class _RcLinkBtnState extends State<_RcLinkBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 12.5,
            color: _hov ? const Color(0xFF2B74AE) : _blue,
            fontWeight: FontWeight.w500,
            decoration: _hov ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

// Item row for Recibo items table
class _RcItemRow extends StatelessWidget {
  final _StockItem item;
  final VoidCallback onDelete;
  const _RcItemRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _sidebarBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 36,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: _ColumnCheckbox(),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${item.id}',
              style: const TextStyle(fontSize: 12, color: _textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(flex: 3, child: _InlineField(hint: '')),
          Expanded(
            flex: 2,
            child: _InlineField(hint: '0', align: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: _InlineField(hint: '0', align: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Text(
                r'$ 0,00',
                style: TextStyle(fontSize: 12.5, color: _textPrimary),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const Text(
                r'$ 0,00',
                style: TextStyle(fontSize: 12.5, color: _textPrimary),
              ),
            ),
          ),
          Expanded(flex: 2, child: _InlineField(hint: '')),
          SizedBox(
            width: 30,
            child: IconButton(
              icon: const Icon(
                Icons.edit_note_rounded,
                size: 14,
                color: _textMuted,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ),
        ],
      ),
    );
  }
}

// Address & Contact tab
class _RcDireccionTab extends StatelessWidget {
  const _RcDireccionTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                // Dirección del Proveedor
                _RcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RcSectionHeader(label: 'Dirección del Proveedor'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Dirección del Proveedor',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Persona de Contacto',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dirección de Envío
                const SizedBox(height: 1),
                _RcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RcSectionHeader(label: 'Dirección de Envío'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Plantilla de Dirección de Despacho',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Plantilla de Dirección de Envío',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dirección de Facturación de la Empresa
                const SizedBox(height: 1),
                _RcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RcSectionHeader(
                        label: 'Dirección de Facturación de la Empresa',
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 400,
                        child: _FormField(
                          label: 'Dirección de Facturación',
                          child: const _TextInputField(hint: ''),
                        ),
                      ),
                    ],
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

// Términos tab
class _RcTerminosTab extends StatelessWidget {
  const _RcTerminosTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                _RcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      // Términos (small input)
                      SizedBox(
                        width: 320,
                        child: _FormField(
                          label: 'Términos',
                          child: const _TextInputField(hint: ''),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Términos y Condiciones with rich-text editor
                      const Text(
                        'Términos y Condiciones',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: _sidebarBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Toolbar
                            Container(
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                border: Border(
                                  bottom: BorderSide(color: _sidebarBorder),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    _RtToolBtn(label: 'Normal'),
                                    _RtDivider(),
                                    _RtIconBtn(icon: Icons.format_bold),
                                    _RtIconBtn(icon: Icons.format_italic),
                                    _RtIconBtn(icon: Icons.format_underline),
                                    _RtIconBtn(icon: Icons.strikethrough_s),
                                    _RtDivider(),
                                    _RtIconBtn(icon: Icons.format_color_text),
                                    _RtIconBtn(icon: Icons.highlight),
                                    _RtDivider(),
                                    _RtIconBtn(icon: Icons.format_quote),
                                    _RtIconBtn(icon: Icons.code),
                                    _RtIconBtn(icon: Icons.wrap_text),
                                    _RtDivider(),
                                    _RtIconBtn(icon: Icons.link),
                                    _RtIconBtn(icon: Icons.image),
                                    _RtDivider(),
                                    _RtIconBtn(
                                      icon: Icons.format_list_bulleted,
                                    ),
                                    _RtIconBtn(
                                      icon: Icons.format_list_numbered,
                                    ),
                                    _RtIconBtn(icon: Icons.checklist),
                                    _RtDivider(),
                                    _RtIconBtn(icon: Icons.format_align_left),
                                    _RtDivider(),
                                    _RtIconBtn(
                                      icon: Icons.format_indent_increase,
                                    ),
                                    _RtIconBtn(
                                      icon: Icons.format_indent_decrease,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                            // Second toolbar row (Table)
                            Container(
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                border: Border(
                                  bottom: BorderSide(color: _sidebarBorder),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Tabla',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.unfold_more_rounded,
                                    size: 14,
                                    color: _textMuted,
                                  ),
                                ],
                              ),
                            ),
                            // Content area
                            Container(
                              height: 180,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: const TextField(
                                maxLines: null,
                                expands: true,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _textPrimary,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// Rich text editor helpers
class _RtToolBtn extends StatelessWidget {
  final String label;
  const _RtToolBtn({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: _sidebarBorder),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: _textPrimary),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_drop_down, size: 14, color: _textMuted),
      ],
    ),
  );
}

class _RtIconBtn extends StatelessWidget {
  final IconData icon;
  const _RtIconBtn({required this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Icon(icon, size: 15, color: _textMuted),
  );
}

class _RtDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 16,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: _sidebarBorder,
  );
}

// Más Información tab
class _RcMasInfoTab extends StatefulWidget {
  const _RcMasInfoTab();

  @override
  State<_RcMasInfoTab> createState() => _RcMasInfoTabState();
}

class _RcMasInfoTabState extends State<_RcMasInfoTab> {
  bool _groupSameItems = false;
  bool _isInternalSupplier = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                // Estado (collapsible)
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Estado',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: SizedBox(
                        width: 260,
                        child: _FormField(
                          label: 'Estado *',
                          child: _DropdownField(
                            value: 'Borrador',
                            items: const ['Borrador', 'Enviado', 'Cancelado'],
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Configuración de Impresión (collapsible)
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Configuración de Impresión',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Membrete de la Empresa',
                                  child: const _ReadOnlyField(
                                    value: 'Membrete de Empresa - Gris',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Encabezado de Impresión',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _groupSameItems,
                                  onChanged: (v) => setState(
                                    () => _groupSameItems = v ?? false,
                                  ),
                                  side: const BorderSide(
                                    color: _sidebarBorder,
                                    width: 1.2,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: _blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Agrupar artículos iguales',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Transportador (collapsible)
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Transportador',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Nombre del Transportador',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _FormField(
                                  label: 'Número de Vehículo',
                                  child: const _TextInputField(hint: ''),
                                ),
                                const SizedBox(height: 12),
                                _FormField(
                                  label: 'Fecha del Vehículo',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Información Adicional
                const SizedBox(height: 1),
                _RcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RcSectionHeader(label: 'Información Adicional'),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Instrucciones',
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: _sidebarBorder),
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFFF8F9FA),
                                ),
                                child: const TextField(
                                  maxLines: null,
                                  expands: true,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Observaciones',
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: _sidebarBorder),
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xFFF8F9FA),
                                ),
                                child: const TextField(
                                  maxLines: null,
                                  expands: true,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: _isInternalSupplier,
                              onChanged: (v) => setState(
                                () => _isInternalSupplier = v ?? false,
                              ),
                              side: const BorderSide(
                                color: _sidebarBorder,
                                width: 1.2,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              activeColor: _blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Es Proveedor Interno',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
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
