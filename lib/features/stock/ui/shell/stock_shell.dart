part of '../stock_screen.dart';

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
    id: 'insights',
    label: 'Smart Insights',
    icon: Icons.insights_rounded,
  ),
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
    id: 'visor',
    label: 'Visor de Inventario',
    icon: Icons.table_chart_rounded,
  ),
  _MenuItem(id: 'reglas', label: 'Reglas de Negocio', icon: Icons.rule_rounded),
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
  final String initialId;

  const StockScreen({
    super.key,
    required this.onBack,
    this.initialId = 'dashboard',
  });

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with TickerProviderStateMixin {
  late String _activeId;
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
    _activeId = widget.initialId;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 980;
            if (desktop) {
              return Scaffold(
                backgroundColor: _bodyBg,
                body: Row(
                  children: [
                    _buildSidebar(),
                    Expanded(child: _buildMainContent()),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: _bodyBg,
              drawer: Drawer(
                width: constraints.maxWidth < 360
                    ? constraints.maxWidth * 0.86
                    : 300,
                child: Builder(
                  builder: (drawerContext) => _buildSidebar(
                    onNavigate: (id) {
                      Navigator.of(drawerContext).pop();
                      _navigate(id);
                    },
                  ),
                ),
              ),
              body: Builder(
                builder: (scaffoldContext) => _buildMainContent(
                  compact: true,
                  onMenu: Scaffold.of(scaffoldContext).openDrawer,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidebar({void Function(String)? onNavigate}) {
    return _Sidebar(
      activeId: _activeId,
      ajusteExpanded: _ajusteExpanded,
      onNavigate: onNavigate ?? _navigate,
      onToggleAjuste: () =>
          setState(() => _ajusteExpanded = !_ajusteExpanded),
      searchCtrl: _searchCtrl,
      searchFocus: _searchFocus,
      onBack: widget.onBack,
    );
  }

  Widget _buildMainContent({bool compact = false, VoidCallback? onMenu}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopBar(activeId: _activeId, compact: compact, onMenu: onMenu),
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
  final bool compact;
  final VoidCallback? onMenu;

  const _TopBar({
    required this.activeId,
    this.compact = false,
    this.onMenu,
  });

  String get _breadcrumb {
    for (final item in _menu) {
      if (item.id == activeId) return item.label;
      for (final child in item.children) {
        if (child.id == activeId) return '${item.label} / ${child.label}';
      }
    }
    if (activeId == 'notificacion') return 'Notificación';
    if (activeId == 'visor') return 'Visor de Inventario';
    if (activeId == 'reglas') return 'Reglas de Negocio';
    if (activeId == 'insights') return 'Smart Insights';
    return activeId;
  }

  @override
  Widget build(BuildContext context) {
    // The list-view pages get a different toolbar
    final isListView =
        activeId == 'transaccion' ||
        activeId == 'recibo' ||
        activeId == 'salida' ||
        activeId == 'solicitud';
    final isManagedView =
        activeId == 'insights' || activeId == 'visor' || activeId == 'reglas';

    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _sidebarBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (onMenu != null) ...[
            IconButton(
              tooltip: 'Abrir navegación',
              onPressed: onMenu,
              icon: const Icon(Icons.menu_rounded, size: 19),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
          ],
          // Breadcrumb
          Text(
            'Stock',
            style: const TextStyle(fontSize: 12.5, color: _textMuted),
          ),
          const Icon(Icons.chevron_right_rounded, size: 15, color: _textMuted),
          Expanded(
            child: Text(
              _breadcrumb,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          if (compact || isManagedView)
            const SizedBox.shrink()
          else if (isListView)
            ..._listToolbar(activeId)
          else
            ..._defaultToolbar(),
        ],
      ),
    );
  }

  List<Widget> _listToolbar(String id) {
    if (id == 'visor') {
      return [
        _DropdownChip(label: 'Vista de Lista', icon: Icons.view_list_rounded),
        const SizedBox(width: 8),
        _DropdownChip(label: 'Filtros guardados', icon: null),
        const SizedBox(width: 8),
        _HoverIcon(icon: Icons.refresh_rounded, onTap: () {}),
        const SizedBox(width: 4),
        _HoverIcon(icon: Icons.download_rounded, onTap: () {}),
      ];
    }
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
      case 'insights':
        return const SmartInsightsView();
      case 'transaccion':
        return const _StockTransactionModule();
      case 'recibo':
        return const _PurchaseReceiptModule();
      case 'salida':
        return const _SalesDeliveryModule();
      case 'solicitud':
        return const _MaterialRequestModule();
      case 'visor':
        return const InventoryView();
      case 'reglas':
        return const BusinessRulesView();
      default:
        return _EmptyState(activeId: activeId);
    }
  }
}
