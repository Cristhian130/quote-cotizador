part of '../stock_screen.dart';

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

