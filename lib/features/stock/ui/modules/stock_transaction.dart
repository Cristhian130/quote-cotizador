part of '../stock_screen.dart';

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

