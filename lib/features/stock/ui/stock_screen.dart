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
        activeId == 'solicitud' ||
        activeId == 'visor';

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
      case 'insights':
        return const _SmartDashboard();
      case 'transaccion':
        return const _TransaccionListView();
      case 'recibo':
        return const _ReciboListView();
      case 'salida':
        return const _SalidaListView();
      case 'solicitud':
        return const _SolicitudListView();
      case 'visor':
        return const _VisorInventarioListView();
      case 'reglas':
        return const _ReglasNegocioPanel();
      default:
        return _EmptyState(activeId: activeId);
    }
  }
}

//  Salida por Venta (Delivery Note) - ERPNext style list view
class _SalidaListView extends StatefulWidget {
  const _SalidaListView();

  @override
  State<_SalidaListView> createState() => _SalidaListViewState();
}

class _SalidaListViewState extends State<_SalidaListView>
    with SingleTickerProviderStateMixin {
  bool _showingForm = false;
  late final AnimationController _formCtrl;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  static const _cols = [
    _ColDef(id: 'id', label: 'ID', flex: 2),
    _ColDef(id: 'cliente', label: 'Cliente', flex: 3),
    _ColDef(id: 'nombre_cliente', label: 'Nombre del Cliente', flex: 3),
    _ColDef(id: 'empresa', label: 'Empresa', flex: 3),
    _ColDef(id: 'bodega_destino', label: 'Bodega de Destino', flex: 3),
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
          child: _SalidaFormView(onBack: _closeForm),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter bar
        _SalidaFilterBar(),

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

        // Empty state matching the Delivery Note screenshot
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
                  const Text(
                    "Aún no has creado ninguna Salida por Venta",
                    style: TextStyle(fontSize: 13.5, color: _textMuted),
                  ),
                  const SizedBox(height: 14),
                  _LinkButton(
                    label: 'Crear tu primera Salida por Venta',
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

class _SalidaFilterBar extends StatefulWidget {
  @override
  State<_SalidaFilterBar> createState() => _SalidaFilterBarState();
}

class _SalidaFilterBarState extends State<_SalidaFilterBar> {
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
          const Icon(Icons.list_rounded, size: 14, color: _textMuted),
          const SizedBox(width: 5),
          const Text(
            'Vista de Lista',
            style: TextStyle(fontSize: 12, color: _textPrimary),
          ),
          const Icon(Icons.unfold_more_rounded, size: 12, color: _textMuted),

          const SizedBox(width: 14),
          const Text(
            'Filtros Guardados',
            style: TextStyle(fontSize: 12, color: _textPrimary),
          ),
          const Icon(Icons.unfold_more_rounded, size: 12, color: _textMuted),

          const SizedBox(width: 14),
          const Icon(Icons.refresh_rounded, size: 14, color: _textMuted),
          const SizedBox(width: 14),
          const Icon(Icons.more_horiz_rounded, size: 14, color: _textMuted),

          const SizedBox(width: 14),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: const Color(
                0xFF192D4D,
              ), // Dark Blue to match the + Add Delivery Note button
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: const [
                Icon(Icons.add, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Agregar Salida por Venta',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          Row(
            children: [
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

//  Solicitud de Material (Material Request) - ERPNext style list view
class _SolicitudListView extends StatefulWidget {
  const _SolicitudListView();

  @override
  State<_SolicitudListView> createState() => _SolicitudListViewState();
}

class _SolicitudListViewState extends State<_SolicitudListView>
    with SingleTickerProviderStateMixin {
  bool _showingForm = false;
  late final AnimationController _formCtrl;
  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  static const _cols = [
    _ColDef(id: 'id', label: 'ID', flex: 2),
    _ColDef(id: 'titulo', label: 'Título', flex: 3),
    _ColDef(id: 'proposito', label: 'Propósito', flex: 3),
    _ColDef(id: 'compania', label: 'Compañía', flex: 3),
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

  void _showForm() {
    setState(() => _showingForm = true);
    _formCtrl.forward();
  }

  void _hideForm() async {
    await _formCtrl.reverse();
    if (mounted) setState(() => _showingForm = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background list view
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SolicitudFilterBar(),
            Expanded(
              child: ColoredBox(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: _sidebarBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Container(
                            width: 32,
                            padding: const EdgeInsets.only(left: 8),
                            child: Checkbox(
                              value: false,
                              onChanged: (_) {},
                              side: const BorderSide(
                                color: _sidebarBorder,
                                width: 1.2,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          ..._cols.map(
                            (c) => Expanded(
                              flex: c.flex,
                              child: _ReciboColHeader(col: c),
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insert_page_break_outlined,
                              size: 48,
                              color: _textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aún no has creado ninguna Solicitud de Material',
                              style: TextStyle(fontSize: 13, color: _textMuted),
                            ),
                            const SizedBox(height: 16),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _showForm,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bodyBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: _sidebarBorder),
                                  ),
                                  child: const Text(
                                    'Crear tu primera Solicitud de Material',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Foreground form view overlay
        if (_showingForm)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: AnimatedBuilder(
                animation: _formCtrl,
                builder: (context, child) {
                  return Opacity(
                    opacity: _formFade.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _formSlide.value.dy)),
                      child: child,
                    ),
                  );
                },
                child: _SolicitudFormView(onBack: _hideForm),
              ),
            ),
          ),
      ],
    );
  }
}

class _SolicitudFilterBar extends StatefulWidget {
  const _SolicitudFilterBar();

  @override
  State<_SolicitudFilterBar> createState() => _SolicitudFilterBarState();
}

class _SolicitudFilterBarState extends State<_SolicitudFilterBar> {
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
          const Icon(Icons.list_rounded, size: 14, color: _textMuted),
          const SizedBox(width: 5),
          const Text(
            'Vista de Lista',
            style: TextStyle(fontSize: 12, color: _textPrimary),
          ),
          const Icon(Icons.unfold_more_rounded, size: 12, color: _textMuted),

          const SizedBox(width: 14),
          const Text(
            'Filtros Guardados',
            style: TextStyle(fontSize: 12, color: _textPrimary),
          ),
          const Icon(Icons.unfold_more_rounded, size: 12, color: _textMuted),

          const SizedBox(width: 14),
          const Icon(Icons.refresh_rounded, size: 14, color: _textMuted),
          const SizedBox(width: 14),
          const Icon(Icons.more_horiz_rounded, size: 14, color: _textMuted),

          const SizedBox(width: 14),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: const Color(
                0xFF192D4D,
              ), // Dark Blue to match the + Add Delivery Note button
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: const [
                Icon(Icons.add, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Agregar Solicitud de Material',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          Row(
            children: [
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

class _SolicitudFormView extends StatefulWidget {
  final VoidCallback onBack;
  const _SolicitudFormView({required this.onBack});

  @override
  State<_SolicitudFormView> createState() => _SolicitudFormViewState();
}

class _SolicitudFormViewState extends State<_SolicitudFormView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // 3 tabs: Detalles, Términos, Más Información
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
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: _sidebarBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.outbox_outlined, size: 15, color: _textMuted),
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
                    'Solicitud de Material',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: _textMuted,
                ),
                const Text(
                  'Nueva Solicitud de Material',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _isSaved
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isSaved ? 'Guardado' : 'No Guardado',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _isSaved
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFED6C02),
                    ),
                  ),
                ),
                const Spacer(),
                // Actions
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7), // _bodyBg
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _sidebarBorder),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Obtener artículos de',
                        style: TextStyle(fontSize: 12, color: _textPrimary),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.unfold_more_rounded,
                        size: 12,
                        color: _textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() => _isSaved = true);
                  },
                  child: Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _darkBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            height: 36,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _sidebarBorder)),
            ),
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              indicatorColor: _activeItem,
              indicatorWeight: 2,
              labelColor: _textPrimary,
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
                Tab(text: 'Términos'),
                Tab(text: 'Más Información'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                const _SolicitudDetallesTab(),
                const _RcTerminosTab(),
                const _SolicitudMasInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalidaFormView extends StatefulWidget {
  final VoidCallback onBack;
  const _SalidaFormView({required this.onBack});

  @override
  State<_SalidaFormView> createState() => _SalidaFormViewState();
}

class _SalidaFormViewState extends State<_SalidaFormView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  bool _isSaved = false;
  String _serie = 'MAT-DN-.YYYY.-';
  bool _editarFechaHora = false;
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
                const Icon(Icons.outbox_outlined, size: 15, color: _textMuted),
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
                    'Salida por Venta',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: _textMuted,
                ),
                const Text(
                  'Nueva Salida por Venta',
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
                // Get Items From
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
                _SalidaDetallesTab(
                  serie: _serie,
                  onSerieChanged: (v) => setState(() => _serie = v),
                  editarFechaHora: _editarFechaHora,
                  onEditarFechaHoraChanged: (v) =>
                      setState(() => _editarFechaHora = v),
                  esDev: _esDev,
                  onEsDevChanged: (v) => setState(() => _esDev = v),
                ),
                const _SalidaDireccionTab(),
                const _RcTerminosTab(),
                const _SalidaMasInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalidaDetallesTab extends StatefulWidget {
  final String serie;
  final ValueChanged<String> onSerieChanged;
  final bool editarFechaHora;
  final ValueChanged<bool> onEditarFechaHoraChanged;
  final bool esDev;
  final ValueChanged<bool> onEsDevChanged;

  const _SalidaDetallesTab({
    required this.serie,
    required this.onSerieChanged,
    required this.editarFechaHora,
    required this.onEditarFechaHoraChanged,
    required this.esDev,
    required this.onEsDevChanged,
  });

  @override
  State<_SalidaDetallesTab> createState() => _SalidaDetallesTabState();
}

class _SalidaDetallesTabState extends State<_SalidaDetallesTab> {
  final List<_StockItem> _items = [_StockItem(id: 1)];
  bool _ignorarRegla = false;

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
                                        'MAT-DN-.YYYY.-',
                                        'DN-.YYYY.-',
                                      ],
                                      onChanged: widget.onSerieChanged,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _FormField(
                                    label: 'Cliente',
                                    required: true,
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
                                  _CheckboxRow(label: 'Es Devolución'),
                                  const SizedBox(height: 14),
                                  _FormField(
                                    label: 'Fecha',
                                    required: true,
                                    child: _ReadOnlyField(
                                      value: '12-03-2026',
                                      editable: widget.editarFechaHora,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _FormField(
                                    label: 'Hora de Publicación',
                                    required: true,
                                    child: _ReadOnlyField(
                                      value: '13:06:25',
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

                        // Dimensiones Contables
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

                        // Moneda y Lista de Precios
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
                                        required: true,
                                        child: const _ReadOnlyField(
                                          value: 'Standard Selling',
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
                                            'Tasa a la que la moneda del cliente se convierte a la moneda base de la empresa',
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
                                            required: true,
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
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Tasa a la que la moneda de la lista de precios se convierte a la moneda base de la empresa',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: _blue,
                                              fontStyle: FontStyle.italic,
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
                                label: 'Bodega de Origen',
                                child: const _TextInputField(hint: ''),
                              ),
                            ),
                          ],
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
                                      child: _TableHeader('Cantidad'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _TableHeader('UDM'),
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
                                      child: _TableHeader('Bodega'),
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

                  // Impuestos y Cargos
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
                            label: 'Plantilla de Impuestos y Cargos de Venta',
                            child: const _TextInputField(hint: ''),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tax table
                        const Text(
                          'Impuestos y Cargos de Venta',
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

                  // Totales (COP)
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
                                  _CheckboxRow(
                                    label: 'Deshabilitar Total Redondeado',
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

                  // Descuento Adicional
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
  final String _fechaPublicacion = '11-03-2026';
  final String _horaPublicacion = '11:40:00';
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

// Salida: Dirección y Contacto tab
class _SalidaDireccionTab extends StatelessWidget {
  const _SalidaDireccionTab();

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
                      _RcSectionHeader(label: 'Dirección de Envío'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Dirección de Envío',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Nombre de la Dirección de Despacho',
                              child: const _TextInputField(hint: ''),
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
                      _RcSectionHeader(label: 'Dirección de la Empresa'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Nombre de la Dirección de la Empresa',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Persona de Contacto de la Empresa',
                              child: const _TextInputField(hint: ''),
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

// Stateful Checkbox Row for new tabs
class _StatefulCheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _StatefulCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            side: const BorderSide(
              color: Color(0xFFD1D8E0), // _sidebarBorder
              width: 1.2,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: const Color(0xFF173A5E), // _blue
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF1F2937), // _textPrimary
          ),
        ),
      ],
    );
  }
}

// Salida: Más Información tab
class _SalidaMasInfoTab extends StatefulWidget {
  const _SalidaMasInfoTab();

  @override
  State<_SalidaMasInfoTab> createState() => _SalidaMasInfoTabState();
}

class _SalidaMasInfoTabState extends State<_SalidaMasInfoTab> {
  bool _printWithoutAmount = false;
  bool _groupSameItems = false;
  bool _isInternalCustomer = false;

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
                  child: _InlineAccordion(
                    title: 'Estado',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: SizedBox(
                        width: 400,
                        child: _FormField(
                          label: 'Estado *',
                          child: const _ReadOnlyField(value: 'Borrador'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Información del Transportista',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Transportista',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Fecha de Recibo de Transporte',
                                  child: const _TextInputField(
                                    hint: 'DD-MM-YYYY',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'No. de Recibo de Transporte',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Nº Vehículo',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Viaje de Entrega',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Nombre del Conductor',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Conductor',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Detalles de la OC del Cliente',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'No. de Orden de Compra del Cliente',
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
                              label: 'Fecha de Orden de Compra del Cliente',
                              child: const _TextInputField(hint: ''),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Comisión',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Socio de Ventas',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Tasa de Comisión (%)',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Monto Elegible para Comisión',
                                  child: const _ReadOnlyField(value: r'$ 0,00'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Comisión Total',
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
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Equipo de Ventas',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Equipo de Ventas',
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
                                        child: _TableHeader('Vendedor *'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _TableHeader('Contribución (%)'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _TableHeader(
                                          'Contribución a Neto...',
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _TableHeader('Tasa de Comisión'),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _TableHeader('Incentivos'),
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
                        ],
                      ),
                    ),
                  ),
                ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Membrete',
                                  child: const _TextInputField(
                                    hint: 'Company Letterhead - Grey',
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
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _StatefulCheckboxRow(
                                      label: 'Imprimir Sin Monto',
                                      value: _printWithoutAmount,
                                      onChanged: (v) => setState(
                                        () => _printWithoutAmount = v ?? false,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _StatefulCheckboxRow(
                                      label: 'Agrupar artículos idénticos',
                                      value: _groupSameItems,
                                      onChanged: (v) => setState(
                                        () => _groupSameItems = v ?? false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Idioma de Impresión',
                                  child: const _TextInputField(hint: 'es'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Analíticas UTM',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Fuente',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Campaña',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Medio',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _FormField(
                                  label: 'Contenido',
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
                const SizedBox(height: 1),
                _RcCard(
                  child: _InlineAccordion(
                    title: 'Información Adicional',
                    initiallyExpanded: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StatefulCheckboxRow(
                                  label: 'Es Cliente Interno',
                                  value: _isInternalCustomer,
                                  onChanged: (v) => setState(
                                    () => _isInternalCustomer = v ?? false,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _FormField(
                                  label: 'Referencia Intercompañía',
                                  child: const _TextInputField(hint: ''),
                                ),
                                const SizedBox(height: 10),
                                _FormField(
                                  label: 'Territorio',
                                  child: const _TextInputField(hint: ''),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Instrucciones',
                              child: Container(
                                height: 160,
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
                    ),
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

// Solicitud de Material: Detalles tab
class _SolicitudDetallesTab extends StatefulWidget {
  const _SolicitudDetallesTab();

  @override
  State<_SolicitudDetallesTab> createState() => _SolicitudDetallesTabState();
}

class _SolicitudDetallesTabState extends State<_SolicitudDetallesTab> {
  String _serie = 'MAT-MR-.YYYY.-';
  String _purpose = 'Purchase';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Container(
        color: const Color(0xFFF4F5F7), // _bodyBg
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RcCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormField(
                            label: 'Serie',
                            required: true,
                            child: _DropdownField(
                              value: _serie,
                              items: const ['MAT-MR-.YYYY.-', 'MR-.YYYY.-'],
                              onChanged: (v) => setState(() => _serie = v),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            label: 'Propósito',
                            required: true,
                            child: _DropdownField(
                              value: _purpose,
                              items: const [
                                'Purchase',
                                'Material Transfer',
                                'Material Issue',
                                'Manufacture',
                                'Customer Provided',
                              ],
                              onChanged: (v) => setState(() => _purpose = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormField(
                            label: 'Fecha de Transacción',
                            required: true,
                            child: const _ReadOnlyField(
                              value: '12-03-2026',
                              editable: false,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            label: 'Requerido Por',
                            child: const _TextInputField(hint: ''),
                          ),
                          const SizedBox(height: 14),
                          _FormField(
                            label: 'Lista de Precios',
                            child: const _TextInputField(
                              hint: 'Standard Buying',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Artículos section
            _RcCard(
              child: _InlineAccordion(
                title: 'Artículos',
                initiallyExpanded: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _FormField(
                              label: 'Escanear Código de Barras',
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 34,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        border: Border.all(
                                          color: const Color(0xFFE2E4E9),
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 34,
                                    width: 34,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF8F9FA),
                                      border: Border(
                                        top: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                        right: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                        bottom: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 16,
                                      color: Color(0xFF8A94A6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _FormField(
                              label: 'Bodega Destino',
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  border: Border.all(
                                    color: const Color(0xFFE2E4E9),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Artículos',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF1C2333),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          border: Border.all(color: const Color(0xFFE2E4E9)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 36,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE2E4E9)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    padding: const EdgeInsets.only(left: 12),
                                    child: _StatefulCheckboxRow(
                                      label: '',
                                      value: false,
                                      onChanged: (v) {},
                                    ),
                                  ),
                                  ...[
                                    _ColDef(id: 'no', label: 'No.', flex: 1),
                                    _ColDef(
                                      id: 'item',
                                      label: 'Código de Artículo',
                                      flex: 4,
                                    ),
                                    _ColDef(
                                      id: 'required_by',
                                      label: 'Requerido Por',
                                      flex: 3,
                                    ),
                                    _ColDef(
                                      id: 'qty',
                                      label: 'Cantidad',
                                      flex: 2,
                                    ),
                                    _ColDef(
                                      id: 'warehouse',
                                      label: 'Bodega',
                                      flex: 3,
                                    ),
                                    _ColDef(id: 'uom', label: 'UDM', flex: 2),
                                  ].map(
                                    (c) => Expanded(
                                      flex: c.flex,
                                      child: _ReciboColHeader(col: c),
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    padding: const EdgeInsets.only(left: 12),
                                    child: _StatefulCheckboxRow(
                                      label: '',
                                      value: false,
                                      onChanged: (v) {},
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF1C2333),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '0,000',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF1C2333),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFE2E4E9),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Container()),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Color(0xFFE2E4E9),
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: Color(0xFF8A94A6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Agregar Fila',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Agregar Múltiples',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Descargar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F5F7), // _bodyBg
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Subir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1C2333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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

// Solicitud de Material: Más Información tab
class _SolicitudMasInfoTab extends StatefulWidget {
  const _SolicitudMasInfoTab();

  @override
  State<_SolicitudMasInfoTab> createState() => _SolicitudMasInfoTabState();
}

class _SolicitudMasInfoTabState extends State<_SolicitudMasInfoTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Container(
        color: const Color(0xFFF4F5F7), // _bodyBg
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RcCard(
              child: _InlineAccordion(
                title: 'Detalles de Impresión',
                initiallyExpanded: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Membrete',
                          child: const _TextInputField(
                            hint: 'Company Letterhead - Grey',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  VISOR DE INVENTARIO — DATA MODEL
// ──────────────────────────────────────────────────────────────────────────────

class _InventarioItem {
  final String idCia;
  final String idInstalacion;
  final String idBodega;
  final String descBodega;
  final double cantExistencia;
  final String ubicacionAux;
  final double costoProm;
  final double ultimoCosto;
  final double cantPendienteEntrar;
  final int rowid;
  final String referencia;
  final String descReferencia;
  final String unidad;
  final double cantTransito;
  final double cantComprometida;
  final String clasificacion;
  final String instalacionId;

  const _InventarioItem({
    required this.idCia,
    required this.idInstalacion,
    required this.idBodega,
    required this.descBodega,
    required this.cantExistencia,
    required this.ubicacionAux,
    required this.costoProm,
    required this.ultimoCosto,
    required this.cantPendienteEntrar,
    required this.rowid,
    required this.referencia,
    required this.descReferencia,
    required this.unidad,
    required this.cantTransito,
    required this.cantComprometida,
    required this.clasificacion,
    required this.instalacionId,
  });
}

const _kDemoInventario = [
  _InventarioItem(
    idCia: '1',
    idInstalacion: '122',
    idBodega: 'PV122',
    descBodega: 'CELESTE MEDELLÍN',
    cantExistencia: 0,
    ubicacionAux: 'SU100101',
    costoProm: 0,
    ultimoCosto: 0,
    cantPendienteEntrar: 0,
    rowid: 4332,
    referencia: '000000000024527185',
    descReferencia: 'ABRAZ BARRA EST N300',
    unidad: 'UNID',
    cantTransito: 0,
    cantComprometida: 0,
    clasificacion: 'ZZ',
    instalacionId: '122',
  ),
  _InventarioItem(
    idCia: '1',
    idInstalacion: '101',
    idBodega: 'PV101',
    descBodega: 'BODEGA BOGOTÁ PRINCIPAL',
    cantExistencia: 45,
    ubicacionAux: 'SU200301',
    costoProm: 12500,
    ultimoCosto: 13000,
    cantPendienteEntrar: 10,
    rowid: 1021,
    referencia: '000000000024527185',
    descReferencia: 'ABRAZ BARRA EST N300',
    unidad: 'UNID',
    cantTransito: 5,
    cantComprometida: 8,
    clasificacion: 'A',
    instalacionId: '101',
  ),
  _InventarioItem(
    idCia: '1',
    idInstalacion: '105',
    idBodega: 'PV105',
    descBodega: 'CALI NORTE',
    cantExistencia: 12,
    ubicacionAux: 'SU300101',
    costoProm: 12300,
    ultimoCosto: 12800,
    cantPendienteEntrar: 0,
    rowid: 2041,
    referencia: '000000000024527185',
    descReferencia: 'ABRAZ BARRA EST N300',
    unidad: 'UNID',
    cantTransito: 0,
    cantComprometida: 2,
    clasificacion: 'AA',
    instalacionId: '105',
  ),
  _InventarioItem(
    idCia: '1',
    idInstalacion: '108',
    idBodega: 'PV108',
    descBodega: 'BARRANQUILLA CENTRO',
    cantExistencia: 3,
    ubicacionAux: 'SU400201',
    costoProm: 12100,
    ultimoCosto: 12600,
    cantPendienteEntrar: 20,
    rowid: 3012,
    referencia: '000000000024527185',
    descReferencia: 'ABRAZ BARRA EST N300',
    unidad: 'UNID',
    cantTransito: 20,
    cantComprometida: 1,
    clasificacion: 'Z',
    instalacionId: '108',
  ),
  _InventarioItem(
    idCia: '1',
    idInstalacion: '112',
    idBodega: 'PV112',
    descBodega: 'BUCARAMANGA',
    cantExistencia: 0,
    ubicacionAux: 'SU500101',
    costoProm: 0,
    ultimoCosto: 12600,
    cantPendienteEntrar: 0,
    rowid: 5001,
    referencia: '000000000024527185',
    descReferencia: 'ABRAZ BARRA EST N300',
    unidad: 'UNID',
    cantTransito: 0,
    cantComprometida: 0,
    clasificacion: 'ZZ',
    instalacionId: '112',
  ),
];

// ──────────────────────────────────────────────────────────────────────────────
//  VISOR MÚLTIPLE DE INVENTARIO — LIST VIEW
// ──────────────────────────────────────────────────────────────────────────────

class _VisorInventarioListView extends StatefulWidget {
  const _VisorInventarioListView();

  @override
  State<_VisorInventarioListView> createState() =>
      _VisorInventarioListViewState();
}

class _VisorInventarioListViewState extends State<_VisorInventarioListView> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filterClasif = 'Todos';
  bool _filterHover = false;

  static const _clasifs = ['Todos', 'A', 'AA', 'Z', 'ZZ'];

  List<_InventarioItem> get _filtered {
    final q = _query.toLowerCase();
    return _kDemoInventario.where((item) {
      final matchQ =
          q.isEmpty ||
          item.referencia.contains(q) ||
          item.descReferencia.toLowerCase().contains(q) ||
          item.descBodega.toLowerCase().contains(q);
      final matchC =
          _filterClasif == 'Todos' || item.clasificacion == _filterClasif;
      return matchQ && matchC;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filterBar(),
        _columnHeader(),
        Expanded(child: rows.isEmpty ? _empty() : _list(rows)),
        _footer(rows.length),
      ],
    );
  }

  Widget _filterBar() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _sidebarBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _filterHover = true),
            onExit: (_) => setState(() => _filterHover = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _filterHover ? _bodyBg : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: _sidebarBorder),
              ),
              child: const Row(
                children: [
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
          const SizedBox(width: 10),
          for (final c in _clasifs) ...[
            _ClasifChip(
              label: c,
              selected: _filterClasif == c,
              onTap: () => setState(() => _filterClasif = c),
            ),
            const SizedBox(width: 4),
          ],
          const Spacer(),
          _VisorSearchBox(
            ctrl: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.sort_rounded, size: 14, color: _textMuted),
          const SizedBox(width: 4),
          const Text(
            'Bodega',
            style: TextStyle(fontSize: 12, color: _textPrimary),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 14,
            color: _textMuted,
          ),
        ],
      ),
    );
  }

  Widget _columnHeader() {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        border: Border(bottom: BorderSide(color: _sidebarBorder)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: _ColumnCheckbox(),
            ),
          ),
          Expanded(flex: 3, child: _VColH('Bodega')),
          Expanded(flex: 3, child: _VColH('Referencia')),
          Expanded(flex: 4, child: _VColH('Descripción')),
          Expanded(flex: 2, child: _VColH('Existencia')),
          Expanded(flex: 2, child: _VColH('En Tránsito')),
          Expanded(flex: 2, child: _VColH('Comprometido')),
          Expanded(flex: 2, child: _VColH('Pend. Entrada')),
          Expanded(flex: 2, child: _VColH('Clasificación')),
        ],
      ),
    );
  }

  Widget _list(List<_InventarioItem> rows) => ColoredBox(
    color: Colors.white,
    child: ListView.builder(
      itemCount: rows.length,
      itemBuilder: (ctx, i) => _InventarioRow(item: rows[i]),
    ),
  );

  Widget _empty() => const ColoredBox(
    color: Colors.white,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_chart_outlined, size: 52, color: Color(0xFFCDD2DA)),
          SizedBox(height: 18),
          Text(
            'No se encontraron registros de inventario',
            style: TextStyle(fontSize: 13.5, color: _textMuted),
          ),
          SizedBox(height: 8),
          Text(
            'Sincronice con la API para obtener datos actualizados',
            style: TextStyle(fontSize: 12, color: _textMuted),
          ),
        ],
      ),
    ),
  );

  Widget _footer(int count) => Container(
    height: 36,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _sidebarBorder)),
    ),
    child: Row(
      children: [
        Text(
          '$count ${count == 1 ? "registro" : "registros"}',
          style: const TextStyle(fontSize: 11.5, color: _textMuted),
        ),
        const Spacer(),
        const Text(
          'Página 1 de 1',
          style: TextStyle(fontSize: 11.5, color: _textMuted),
        ),
      ],
    ),
  );
}

// ── Inventory row ─────────────────────────────────────────────────────────────

class _InventarioRow extends StatefulWidget {
  final _InventarioItem item;
  const _InventarioRow({required this.item});

  @override
  State<_InventarioRow> createState() => _InventarioRowState();
}

class _InventarioRowState extends State<_InventarioRow> {
  bool _hovered = false;

  static Color _clasifColor(String c) {
    switch (c) {
      case 'A':
        return const Color(0xFF2BAE7E);
      case 'AA':
        return const Color(0xFF458AC9);
      case 'Z':
        return const Color(0xFFE67E22);
      case 'ZZ':
        return const Color(0xFFE53935);
      default:
        return _textMuted;
    }
  }

  static String _fmt(double v) =>
      v == 0 ? '—' : v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cc = _clasifColor(item.clasificacion);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hovered ? const Color(0xFFF5F8FC) : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 44,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: _ColumnCheckbox(),
                  ),
                ),
                // Bodega
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.descBodega,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.idBodega} · Inst. ${item.idInstalacion}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Referencia
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      item.referencia,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _blue,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Descripción
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      item.descReferencia,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _VNum(
                    value: _fmt(item.cantExistencia),
                    unit: item.unidad,
                  ),
                ),
                Expanded(flex: 2, child: _VNum(value: _fmt(item.cantTransito))),
                Expanded(
                  flex: 2,
                  child: _VNum(value: _fmt(item.cantComprometida)),
                ),
                Expanded(
                  flex: 2,
                  child: _VNum(value: _fmt(item.cantPendienteEntrar)),
                ),
                // Clasificación badge
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: cc.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: cc.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item.clasificacion,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cc,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 1, color: _sidebarBorder),
          ],
        ),
      ),
    );
  }
}

// ── Micro-helpers ─────────────────────────────────────────────────────────────

class _VNum extends StatelessWidget {
  final String value;
  final String? unit;
  const _VNum({required this.value, this.unit});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            color: value == '—' ? _textMuted : _textPrimary,
            fontWeight: value == '—' ? FontWeight.w400 : FontWeight.w500,
          ),
        ),
        if (unit != null)
          Text(unit!, style: const TextStyle(fontSize: 10, color: _textMuted)),
      ],
    ),
  );
}

class _VColH extends StatelessWidget {
  final String label;
  const _VColH(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: _textMuted,
        letterSpacing: 0.1,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class _ClasifChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ClasifChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static Color _color(String c) {
    switch (c) {
      case 'A':
        return const Color(0xFF2BAE7E);
      case 'AA':
        return const Color(0xFF458AC9);
      case 'Z':
        return const Color(0xFFE67E22);
      case 'ZZ':
        return const Color(0xFFE53935);
      default:
        return _textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cc = _color(label);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? cc.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? cc.withOpacity(0.5) : _sidebarBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? cc : _textMuted,
          ),
        ),
      ),
    );
  }
}

class _VisorSearchBox extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  const _VisorSearchBox({required this.ctrl, required this.onChanged});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    height: 30,
    child: TextField(
      controller: ctrl,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 12.5, color: _textPrimary),
      decoration: InputDecoration(
        hintText: 'Buscar referencia o bodega…',
        hintStyle: const TextStyle(fontSize: 12, color: _textMuted),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 15,
          color: _textMuted,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 30,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: _sidebarBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: _sidebarBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: _blue.withOpacity(0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        isDense: true,
        filled: true,
        fillColor: _bodyBg,
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  MOTOR DE ALERTAS — DATA MODELS
// ══════════════════════════════════════════════════════════════════════════════

enum _ReglaTipo { diasInventario, stockAltoRotBaja, difCiudades }

enum _AccionSugerida { descuento, traslado, priorizar }

class _Regla {
  final String id;
  final String nombre;
  final _ReglaTipo tipo;
  final double umbral;
  final _AccionSugerida accion;
  final double valorAccion;
  final bool activa;

  _Regla({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.umbral,
    required this.accion,
    required this.valorAccion,
    this.activa = true,
  });

  _Regla copyWith({
    String? nombre,
    _ReglaTipo? tipo,
    double? umbral,
    _AccionSugerida? accion,
    double? valorAccion,
    bool? activa,
  }) => _Regla(
    id: id,
    nombre: nombre ?? this.nombre,
    tipo: tipo ?? this.tipo,
    umbral: umbral ?? this.umbral,
    accion: accion ?? this.accion,
    valorAccion: valorAccion ?? this.valorAccion,
    activa: activa ?? this.activa,
  );
}

List<_Regla> _reglasState = [
  _Regla(
    id: 'r1',
    nombre: 'Inventario estancado > 90 días',
    tipo: _ReglaTipo.diasInventario,
    umbral: 90,
    accion: _AccionSugerida.descuento,
    valorAccion: 15,
    activa: true,
  ),
  _Regla(
    id: 'r2',
    nombre: 'Stock alto con baja rotación (ZZ)',
    tipo: _ReglaTipo.stockAltoRotBaja,
    umbral: 50,
    accion: _AccionSugerida.traslado,
    valorAccion: 20,
    activa: true,
  ),
  _Regla(
    id: 'r3',
    nombre: 'Diferencia de inventario entre ciudades',
    tipo: _ReglaTipo.difCiudades,
    umbral: 30,
    accion: _AccionSugerida.traslado,
    valorAccion: 10,
    activa: false,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  PANEL PRINCIPAL
// ══════════════════════════════════════════════════════════════════════════════

class _ReglasNegocioPanel extends StatefulWidget {
  const _ReglasNegocioPanel();

  @override
  State<_ReglasNegocioPanel> createState() => _ReglasNegocioPanelState();
}

class _ReglasNegocioPanelState extends State<_ReglasNegocioPanel> {
  late List<_Regla> _reglas;
  _Regla? _editando;
  bool _creandoNueva = false;

  @override
  void initState() {
    super.initState();
    _reglas = List.from(_reglasState);
  }

  void _guardar(_Regla r) {
    setState(() {
      final idx = _reglas.indexWhere((x) => x.id == r.id);
      if (idx >= 0) {
        _reglas[idx] = r;
      } else {
        _reglas.add(r);
      }
      _reglasState = _reglas;
      _editando = null;
      _creandoNueva = false;
    });
  }

  void _eliminar(String id) {
    setState(() {
      _reglas.removeWhere((r) => r.id == id);
      _reglasState = _reglas;
      if (_editando?.id == id) _editando = null;
    });
  }

  void _toggleActiva(String id) {
    setState(() {
      final idx = _reglas.indexWhere((r) => r.id == id);
      if (idx >= 0) {
        _reglas[idx] = _reglas[idx].copyWith(activa: !_reglas[idx].activa);
      }
      _reglasState = _reglas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bodyBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: list + editor
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.rule_rounded,
                          color: _blue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Panel de Administración de Reglas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          Text(
                            'Configura las reglas que activan alertas y sugerencias automáticas',
                            style: TextStyle(fontSize: 11.5, color: _textMuted),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _PrimaryButton(
                        label: '+ Nueva Regla',
                        onTap: () => setState(() {
                          _creandoNueva = true;
                          _editando = _Regla(
                            id: 'r${DateTime.now().millisecondsSinceEpoch}',
                            nombre: '',
                            tipo: _ReglaTipo.diasInventario,
                            umbral: 90,
                            accion: _AccionSugerida.descuento,
                            valorAccion: 10,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Rules list ──────────────────────────────────────────────
                  ..._reglas.map(
                    (r) => _ReglaCard(
                      regla: r,
                      isEditing: _editando?.id == r.id,
                      onEdit: () => setState(() => _editando = r.copyWith()),
                      onToggle: () => _toggleActiva(r.id),
                      onDelete: () => _eliminar(r.id),
                      onCancelEdit: () => setState(() => _editando = null),
                      onSave: _guardar,
                    ),
                  ),

                  // New rule form ───────────────────────────────────────────
                  if (_creandoNueva && _editando != null)
                    _ReglaEditorCard(
                      regla: _editando!,
                      isNew: true,
                      onSave: _guardar,
                      onCancel: () => setState(() {
                        _editando = null;
                        _creandoNueva = false;
                      }),
                    ),

                  if (_reglas.isEmpty && !_creandoNueva)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _sidebarBorder),
                      ),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(
                              Icons.rule_folder_outlined,
                              size: 40,
                              color: _textMuted,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No hay reglas configuradas',
                              style: TextStyle(fontSize: 13, color: _textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Right: alerts preview ───────────────────────────────────────────
          Container(
            width: 270,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: _sidebarBorder)),
            ),
            child: _AlertasPreview(reglas: _reglas),
          ),
        ],
      ),
    );
  }
}

// ── Rule card (read mode + inline editor) ─────────────────────────────────────

class _ReglaCard extends StatelessWidget {
  final _Regla regla;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onCancelEdit;
  final void Function(_Regla) onSave;

  const _ReglaCard({
    required this.regla,
    required this.isEditing,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.onCancelEdit,
    required this.onSave,
  });

  Color get _tipoColor {
    switch (regla.tipo) {
      case _ReglaTipo.diasInventario:
        return const Color(0xFF7B5FF5);
      case _ReglaTipo.stockAltoRotBaja:
        return const Color(0xFFE67E22);
      case _ReglaTipo.difCiudades:
        return const Color(0xFF458AC9);
    }
  }

  String get _tipoLabel {
    switch (regla.tipo) {
      case _ReglaTipo.diasInventario:
        return 'Días en inventario';
      case _ReglaTipo.stockAltoRotBaja:
        return 'Stock alto + baja rotación';
      case _ReglaTipo.difCiudades:
        return 'Diferencia entre ciudades';
    }
  }

  String get _accionLabel {
    switch (regla.accion) {
      case _AccionSugerida.descuento:
        return '${regla.valorAccion.toInt()}% descuento';
      case _AccionSugerida.traslado:
        return 'Trasladar ${regla.valorAccion.toInt()} uds';
      case _AccionSugerida.priorizar:
        return 'Priorizar venta';
    }
  }

  IconData get _accionIcon {
    switch (regla.accion) {
      case _AccionSugerida.descuento:
        return Icons.local_offer_rounded;
      case _AccionSugerida.traslado:
        return Icons.swap_horiz_rounded;
      case _AccionSugerida.priorizar:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return _ReglaEditorCard(
        regla: regla,
        isNew: false,
        onSave: onSave,
        onCancel: onCancelEdit,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: regla.activa ? _tipoColor.withOpacity(0.3) : _sidebarBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _tipoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: _tipoColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _tipoLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _tipoColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    regla.nombre,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: regla.activa ? _textPrimary : _textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _RChip(
                        icon: Icons.timer_outlined,
                        label: 'Umbral: ${regla.umbral.toInt()}',
                        color: _textMuted,
                      ),
                      const SizedBox(width: 8),
                      _RChip(
                        icon: _accionIcon,
                        label: _accionLabel,
                        color: const Color(0xFF2BAE7E),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _IAToggle(value: regla.activa, onChanged: (_) => onToggle()),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _HoverIcon(
                      icon: Icons.edit_rounded,
                      size: 16,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 2),
                    _HoverIcon(
                      icon: Icons.delete_outline_rounded,
                      size: 16,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rule editor form ──────────────────────────────────────────────────────────

class _ReglaEditorCard extends StatefulWidget {
  final _Regla regla;
  final bool isNew;
  final void Function(_Regla) onSave;
  final VoidCallback onCancel;

  const _ReglaEditorCard({
    required this.regla,
    required this.isNew,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_ReglaEditorCard> createState() => _ReglaEditorCardState();
}

class _ReglaEditorCardState extends State<_ReglaEditorCard> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _umbralCtrl;
  late final TextEditingController _valorCtrl;
  late _ReglaTipo _tipo;
  late _AccionSugerida _accion;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.regla.nombre);
    _umbralCtrl = TextEditingController(
      text: widget.regla.umbral.toInt().toString(),
    );
    _valorCtrl = TextEditingController(
      text: widget.regla.valorAccion.toInt().toString(),
    );
    _tipo = widget.regla.tipo;
    _accion = widget.regla.accion;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _umbralCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  String get _umbralSuffix {
    switch (_tipo) {
      case _ReglaTipo.diasInventario:
        return 'días';
      case _ReglaTipo.stockAltoRotBaja:
        return 'unidades';
      case _ReglaTipo.difCiudades:
        return '% diferencia';
    }
  }

  String get _accionSuffix {
    switch (_accion) {
      case _AccionSugerida.descuento:
        return '% de descuento';
      case _AccionSugerida.traslado:
        return 'unidades a trasladar';
      case _AccionSugerida.priorizar:
        return '(sin valor adicional)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _blue.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.isNew ? 'Nueva Regla' : 'Editar Regla',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                _HoverIcon(
                  icon: Icons.close_rounded,
                  size: 16,
                  onTap: widget.onCancel,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: _sidebarBorder, height: 1),
            const SizedBox(height: 14),

            // Nombre
            _FormField(
              label: 'Nombre de la regla',
              required: true,
              child: _RTextField(
                ctrl: _nombreCtrl,
                hint: 'Ej. Stock inmovilizado Bogotá',
              ),
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Tipo de condición',
                    required: true,
                    child: _RDropdown<_ReglaTipo>(
                      value: _tipo,
                      items: const {
                        _ReglaTipo.diasInventario: 'Inventario > X días',
                        _ReglaTipo.stockAltoRotBaja:
                            'Stock alto + baja rotación',
                        _ReglaTipo.difCiudades: 'Diferencia entre ciudades',
                      },
                      onChanged: (v) => setState(() => _tipo = v),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 150,
                  child: _FormField(
                    label: 'Umbral ($_umbralSuffix)',
                    required: true,
                    child: _RTextField(
                      ctrl: _umbralCtrl,
                      hint: '90',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Acción separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Sugerencia automática',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Divider(color: _sidebarBorder, height: 1),
                  ),
                ],
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Acción sugerida',
                    required: true,
                    child: _RDropdown<_AccionSugerida>(
                      value: _accion,
                      items: const {
                        _AccionSugerida.descuento: '💰 Aplicar descuento',
                        _AccionSugerida.traslado: '🚚 Trasladar producto',
                        _AccionSugerida.priorizar: '⭐ Priorizar venta',
                      },
                      onChanged: (v) => setState(() => _accion = v),
                    ),
                  ),
                ),
                if (_accion != _AccionSugerida.priorizar) ...[
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 150,
                    child: _FormField(
                      label: 'Valor ($_accionSuffix)',
                      child: _RTextField(
                        ctrl: _valorCtrl,
                        hint: '10',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _bodyBg,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: _sidebarBorder),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 12.5, color: _textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    final nombre = _nombreCtrl.text.trim();
                    if (nombre.isEmpty) return;
                    widget.onSave(
                      widget.regla.copyWith(
                        nombre: nombre,
                        tipo: _tipo,
                        umbral: double.tryParse(_umbralCtrl.text) ?? 90,
                        accion: _accion,
                        valorAccion: double.tryParse(_valorCtrl.text) ?? 10,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _darkBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Right panel: alerts preview ───────────────────────────────────────────────

class _AlertasPreview extends StatelessWidget {
  final List<_Regla> reglas;
  const _AlertasPreview({required this.reglas});

  @override
  Widget build(BuildContext context) {
    final activas = reglas.where((r) => r.activa).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _sidebarBorder)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                size: 15,
                color: _blue,
              ),
              const SizedBox(width: 8),
              const Text(
                'Alertas Activas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: activas.isEmpty ? _bodyBg : _blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activas.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: activas.isEmpty ? _textMuted : _blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: activas.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 36,
                        color: Color(0xFF2BAE7E),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sin alertas activas',
                        style: TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: activas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _AlertaCard(regla: activas[i]),
                ),
        ),

        // Footer tip
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _sidebarBorder)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 13, color: _textMuted),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Las alertas se evalúan al sincronizar con la API.',
                  style: TextStyle(fontSize: 10.5, color: _textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final _Regla regla;
  const _AlertaCard({required this.regla});

  Color get _color {
    switch (regla.tipo) {
      case _ReglaTipo.diasInventario:
        return const Color(0xFF7B5FF5);
      case _ReglaTipo.stockAltoRotBaja:
        return const Color(0xFFE67E22);
      case _ReglaTipo.difCiudades:
        return const Color(0xFF458AC9);
    }
  }

  IconData get _icon {
    switch (regla.accion) {
      case _AccionSugerida.descuento:
        return Icons.local_offer_rounded;
      case _AccionSugerida.traslado:
        return Icons.swap_horiz_rounded;
      case _AccionSugerida.priorizar:
        return Icons.star_rounded;
    }
  }

  String get _accionText {
    switch (regla.accion) {
      case _AccionSugerida.descuento:
        return 'Aplicar ${regla.valorAccion.toInt()}% descuento';
      case _AccionSugerida.traslado:
        return 'Trasladar ${regla.valorAccion.toInt()} uds';
      case _AccionSugerida.priorizar:
        return 'Priorizar venta';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(_icon, size: 14, color: _color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  regla.nombre,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _accionText,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: _color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Editor form helpers ───────────────────────────────────────────────────────

class _RTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType keyboardType;

  const _RTextField({
    required this.ctrl,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 34,
    decoration: BoxDecoration(
      color: _bodyBg,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: _sidebarBorder),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12.5, color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12.5, color: _textMuted),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        isDense: true,
      ),
    ),
  );
}

class _RDropdown<T> extends StatelessWidget {
  final T value;
  final Map<T, String> items;
  final void Function(T) onChanged;

  const _RDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: _bodyBg,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: _sidebarBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: _textMuted,
        ),
        style: const TextStyle(fontSize: 12.5, color: _textPrimary),
        items: items.entries
            .map(
              (e) => DropdownMenuItem<T>(
                value: e.key,
                child: Text(
                  e.value,
                  style: const TextStyle(fontSize: 12.5, color: _textPrimary),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    ),
  );
}

class _RChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _IAToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IAToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 20,
      decoration: BoxDecoration(
        color: value ? _blue : const Color(0xFFCDD2DA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  SMART DASHBOARD — Punto 3
// ══════════════════════════════════════════════════════════════════════════════

class _SmartDashboard extends StatelessWidget {
  const _SmartDashboard();

  // --------------------------------------------------------------------------
  // Derive action cards from active rules + demo inventory
  // --------------------------------------------------------------------------
  List<_ActionCard> _buildActions() {
    final actions = <_ActionCard>[];
    final activeRules = _reglasState.where((r) => r.activa).toList();

    for (final rule in activeRules) {
      // Find inventory items that match this rule type
      final relevant = _kDemoInventario.where((item) {
        switch (rule.tipo) {
          case _ReglaTipo.diasInventario:
            return item.cantExistencia == 0 && item.clasificacion == 'ZZ';
          case _ReglaTipo.stockAltoRotBaja:
            return item.cantExistencia >= rule.umbral ||
                item.clasificacion == 'ZZ';
          case _ReglaTipo.difCiudades:
            return item.cantTransito > 0;
        }
      }).toList();

      for (final item in relevant) {
        actions.add(_ActionCard(regla: rule, item: item));
      }
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions();
    return Container(
      color: _bodyBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B5FF5), Color(0xFF458AC9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Smart Insights',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      'Sugerencias y alertas inteligentes basadas en tus reglas de negocio',
                      style: TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── KPI Strip ─────────────────────────────────────────────────
            _KpiStrip(actions: actions),
            const SizedBox(height: 24),

            // ── Two-column layout ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: action suggestions
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.auto_fix_high_rounded,
                        title: 'Sugerencias Inteligentes',
                        badge: '${actions.length}',
                        badgeColor: const Color(0xFF7B5FF5),
                      ),
                      const SizedBox(height: 12),
                      if (actions.isEmpty)
                        _EmptyActionState()
                      else
                        ...actions.map((a) => _ActionCardTile(card: a)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Right: warehouse heat-map
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        icon: Icons.map_outlined,
                        title: 'Mapa de Bodegas',
                        badge: '5',
                        badgeColor: Color(0xFF2BAE7E),
                      ),
                      const SizedBox(height: 12),
                      _WarehouseHeatmap(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPI Strip ─────────────────────────────────────────────────────────────────

class _KpiStrip extends StatelessWidget {
  final List<_ActionCard> actions;
  const _KpiStrip({required this.actions});

  @override
  Widget build(BuildContext context) {
    final totalBodegas = _kDemoInventario.length;
    final sinStock = _kDemoInventario
        .where((i) => i.cantExistencia == 0)
        .length;
    final clasifZZ = _kDemoInventario
        .where((i) => i.clasificacion == 'ZZ')
        .length;
    final activeRules = _reglasState.where((r) => r.activa).length;

    return Row(
      children: [
        _Kpi(
          label: 'Bodegas monitoreadas',
          value: '$totalBodegas',
          icon: Icons.warehouse_rounded,
          color: _blue,
        ),
        const SizedBox(width: 14),
        _Kpi(
          label: 'Sin existencias',
          value: '$sinStock',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFFE67E22),
        ),
        const SizedBox(width: 14),
        _Kpi(
          label: 'Clasif. crítica (ZZ)',
          value: '$clasifZZ',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFE53935),
        ),
        const SizedBox(width: 14),
        _Kpi(
          label: 'Reglas activas',
          value: '$activeRules',
          icon: Icons.rule_rounded,
          color: const Color(0xFF7B5FF5),
        ),
        const SizedBox(width: 14),
        _Kpi(
          label: 'Sugerencias generadas',
          value: '${actions.length}',
          icon: Icons.auto_fix_high_rounded,
          color: const Color(0xFF2BAE7E),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _sidebarBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10.5, color: _textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final Color badgeColor;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: badgeColor),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Action card model ─────────────────────────────────────────────────────────

class _ActionCard {
  final _Regla regla;
  final _InventarioItem item;
  const _ActionCard({required this.regla, required this.item});
}

// ── Action card tile ──────────────────────────────────────────────────────────

class _ActionCardTile extends StatefulWidget {
  final _ActionCard card;
  const _ActionCardTile({required this.card});

  @override
  State<_ActionCardTile> createState() => _ActionCardTileState();
}

class _ActionCardTileState extends State<_ActionCardTile> {
  bool _hovered = false;
  bool _done = false;

  Color get _accentColor {
    switch (widget.card.regla.accion) {
      case _AccionSugerida.descuento:
        return const Color(0xFF2BAE7E);
      case _AccionSugerida.traslado:
        return const Color(0xFF458AC9);
      case _AccionSugerida.priorizar:
        return const Color(0xFF7B5FF5);
    }
  }

  IconData get _accentIcon {
    switch (widget.card.regla.accion) {
      case _AccionSugerida.descuento:
        return Icons.local_offer_rounded;
      case _AccionSugerida.traslado:
        return Icons.swap_horiz_rounded;
      case _AccionSugerida.priorizar:
        return Icons.star_rounded;
    }
  }

  String get _accionText {
    switch (widget.card.regla.accion) {
      case _AccionSugerida.descuento:
        return 'Aplicar ${widget.card.regla.valorAccion.toInt()}% de descuento';
      case _AccionSugerida.traslado:
        return 'Trasladar ${widget.card.regla.valorAccion.toInt()} unidades';
      case _AccionSugerida.priorizar:
        return 'Priorizar en ventas';
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.card.item;
    final regla = widget.card.regla;

    return AnimatedOpacity(
      opacity: _done ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _hovered ? _accentColor.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? _accentColor.withOpacity(0.35) : _sidebarBorder,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(_accentIcon, color: _accentColor, size: 17),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rule name
                      Text(
                        regla.nombre,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Product
                      Text(
                        item.descReferencia,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Tags row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _SmTag(
                            text: item.descBodega,
                            color: _textMuted,
                            icon: Icons.warehouse_rounded,
                          ),
                          _SmTag(
                            text:
                                'Exist: ${item.cantExistencia.toInt()} ${item.unidad}',
                            color: item.cantExistencia == 0
                                ? const Color(0xFFE53935)
                                : _textMuted,
                            icon: Icons.inventory_2_outlined,
                          ),
                          _SmTag(
                            text: 'Clasif: ${item.clasificacion}',
                            color:
                                item.clasificacion == 'ZZ' ||
                                    item.clasificacion == 'Z'
                                ? const Color(0xFFE67E22)
                                : const Color(0xFF2BAE7E),
                            icon: Icons.label_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Action button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _done = !_done),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _done ? _bodyBg : _accentColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _done ? _sidebarBorder : _accentColor,
                          ),
                        ),
                        child: Text(
                          _done ? 'Deshacer' : _accionText,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _done ? _textMuted : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_done)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '✓ Aplicado',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: const Color(0xFF2BAE7E),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmTag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _SmTag({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 10.5, color: color)),
      ],
    ),
  );
}

class _EmptyActionState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _sidebarBorder),
    ),
    child: const Center(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: Color(0xFF2BAE7E),
          ),
          SizedBox(height: 14),
          Text(
            'Sin sugerencias pendientes',
            style: TextStyle(fontSize: 13.5, color: _textMuted),
          ),
          SizedBox(height: 6),
          Text(
            'Activa reglas en "Reglas de Negocio" para generar alertas',
            style: TextStyle(fontSize: 11.5, color: _textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// ── Warehouse Heat-map ─────────────────────────────────────────────────────────

class _WarehouseHeatmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _kDemoInventario
          .map((item) => _WarehouseRow(item: item))
          .toList(),
    );
  }
}

class _WarehouseRow extends StatefulWidget {
  final _InventarioItem item;
  const _WarehouseRow({required this.item});

  @override
  State<_WarehouseRow> createState() => _WarehouseRowState();
}

class _WarehouseRowState extends State<_WarehouseRow> {
  bool _hovered = false;

  Color _statusColor(String clasif, double exist) {
    if (exist == 0) return const Color(0xFFE53935);
    switch (clasif) {
      case 'A':
        return const Color(0xFF2BAE7E);
      case 'AA':
        return const Color(0xFF458AC9);
      case 'Z':
        return const Color(0xFFE67E22);
      case 'ZZ':
        return const Color(0xFFE53935);
      default:
        return _textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = _statusColor(item.clasificacion, item.cantExistencia);

    // Fill ratio capped at 1.0, using max stock in the set as reference (45)
    final ratio = (item.cantExistencia / 45.0).clamp(0.0, 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hovered ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered ? color.withOpacity(0.3) : _sidebarBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.descBodega,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.clasificacion,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: _sidebarBorder,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${item.cantExistencia.toInt()} ${item.unidad}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (item.cantTransito > 0)
                  Text(
                    '+${item.cantTransito.toInt()} en tránsito',
                    style: const TextStyle(fontSize: 10, color: _textMuted),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
