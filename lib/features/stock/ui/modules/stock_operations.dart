part of '../stock_screen.dart';

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

