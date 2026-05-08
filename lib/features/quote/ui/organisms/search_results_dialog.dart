import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/ia_colors.dart';

const Color _lightBlue = Color(0xFF458AC9);

class SearchResultsDialog extends StatefulWidget {
  final List<Product> products;
  final void Function(List<Product> selected) onAddSelected;

  const SearchResultsDialog({
    super.key,
    required this.products,
    required this.onAddSelected,
  });

  static Future<void> show(
    BuildContext context,
    List<Product> products,
    void Function(List<Product>) onAddSelected,
  ) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) =>
          SearchResultsDialog(products: products, onAddSelected: onAddSelected),
    );
  }

  @override
  State<SearchResultsDialog> createState() => _SearchResultsDialogState();
}

class _SearchResultsDialogState extends State<SearchResultsDialog>
    with SingleTickerProviderStateMixin {
  // ← index-based: fixes the "all selected" bug caused by shared referencia
  // Use a composite key (ref + bodega) because the same reference can exist in multiple warehouses
  final Set<String> _selectedIds = {};
  /// Track edited descriptions by product reference (since indices might change if we filtered, 
  /// though here products is usually static for the dialog instance).
  final Map<String, String> _editedDescriptions = {};
  bool _sortByDescription = false;
  String _localFilter = '';
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  String _formatPrice(double v) => NumberFormat.simpleCurrency(
    locale: 'es_CO',
    name: '',
    decimalDigits: 0,
  ).format(v);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts() {
    var filtered = List<Product>.from(widget.products);
    if (_localFilter.isNotEmpty) {
      final q = _localFilter.toLowerCase();
      filtered = filtered.where((p) => p.descripcion.toLowerCase().contains(q)).toList();
    }
    if (_sortByDescription) {
      filtered.sort((a, b) => a.descripcion.compareTo(b.descripcion));
    }
    return filtered;
  }

  String _getItemId(Product p) => '${p.referencia}_${p.bodega}';

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleAll() {
    final currentVisible = _getFilteredProducts();
    final currentVisibleIds = currentVisible.map(_getItemId).toSet();
    
    setState(() {
      if (_selectedIds.containsAll(currentVisibleIds)) {
        _selectedIds.removeAll(currentVisibleIds);
      } else {
        _selectedIds.addAll(currentVisibleIds);
      }
    });
  }

  void _confirm() {
    final sel = _selectedIds.map((id) {
      // Split the composite ID to find the product correctly
      final parts = id.split('_');
      final ref = parts[0];
      final bodega = parts[1];
      
      final p = widget.products.firstWhere(
        (p) => p.referencia == ref && p.bodega == bodega,
      );
      final edited = _editedDescriptions[p.referencia];
      return edited != null ? p.copyWith(descripcion: edited) : p;
    }).toList();
    Navigator.of(context).pop();
    widget.onAddSelected(sel);
  }

  bool get _allSelected {
    final currentVisible = _getFilteredProducts();
    if (currentVisible.isEmpty) return false;
    final currentVisibleIds = currentVisible.map(_getItemId).toSet();
    return _selectedIds.containsAll(currentVisibleIds);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(_anim),
      child: FadeTransition(
        opacity: _anim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 60,
            vertical: 40,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 920, maxHeight: 640),
            decoration: BoxDecoration(
              color: IaColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: IaColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                _buildColumnHeaders(),
                Expanded(child: _buildRows()),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
      decoration: BoxDecoration(
        color: IaColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: IaColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.search, color: _lightBlue, size: 17),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resultados',
                style: TextStyle(
                  color: IaColors.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.products.length} encontrados',
                style: const TextStyle(
                  color: IaColors.mutedForeground,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          // Buscador inteligente local
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: IaColors.muted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: IaColors.border),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _localFilter = v),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Filtrar descripción...',
                  hintStyle: TextStyle(
                    color: IaColors.mutedForeground.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.filter_list, size: 16, color: _lightBlue),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  suffixIcon: _localFilter.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 14),
                        onPressed: () => setState(() => _localFilter = ''),
                      )
                    : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          _selectAllButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: IaColors.mutedForeground,
              size: 19,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _selectAllButton() {
    return InkWell(
      onTap: _toggleAll,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _allSelected
              ? _lightBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _allSelected ? _lightBlue.withOpacity(0.3) : IaColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _allSelected ? Icons.deselect : Icons.select_all,
              color: _allSelected ? _lightBlue : IaColors.foreground,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              _allSelected ? 'Quitar selección' : 'Seleccionar todo',
              style: TextStyle(
                color: _allSelected ? _lightBlue : IaColors.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: IaColors.muted.withOpacity(0.3),
      child: Row(
        children: [
          const SizedBox(width: 44),
          _hdr('REFERENCIA', flex: 2),
          _hdr(
            'DESCRIPCIÓN',
            flex: 4,
            isSortable: true,
            isSorted: _sortByDescription,
            onTap: () => setState(() => _sortByDescription = !_sortByDescription),
          ),
          _hdr('BODEGA', flex: 1),
          _hdr('DISP.', flex: 1, align: TextAlign.center),
          _hdr('PRECIO', flex: 2, align: TextAlign.right),
          _hdr('PRECIO + IVA', flex: 2, align: TextAlign.right),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildRows() {
    final filtered = _getFilteredProducts();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
          final product = filtered[i];
          final itemId = _getItemId(product);
          return _ProductRow(
            key: ValueKey(itemId),
            index: i,
            product: product,
            editedDescription: _editedDescriptions[product.referencia],
            isSelected: _selectedIds.contains(itemId),
            formatPrice: _formatPrice,
            onToggle: () => _toggle(itemId),
            onDescriptionChanged: (val) {
              setState(() {
                _editedDescriptions[product.referencia] = val;
              });
            },
            onAddSingle: () {
              final p = product;
              final edited = _editedDescriptions[p.referencia];
              final finalProduct =
                  edited != null ? p.copyWith(descripcion: edited) : p;
              Navigator.of(context).pop();
              widget.onAddSelected([finalProduct]);
            },
          );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: IaColors.card,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: IaColors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (_selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _lightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lightBlue.withOpacity(0.3)),
              ),
              child: Text(
                '${_selectedIds.length} seleccionado${_selectedIds.length != 1 ? 's' : ''}',
                style: const TextStyle(color: _lightBlue, fontSize: 12),
              ),
            ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: IaColors.mutedForeground),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedOpacity(
            opacity: _selectedIds.isNotEmpty ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: _selectedIds.isNotEmpty ? _confirm : null,
              icon: const Icon(Icons.add_shopping_cart, size: 15),
              label: Text(
                _selectedIds.isEmpty
                    ? 'Agregar a factura'
                    : 'Agregar ${_selectedIds.length} producto${_selectedIds.length != 1 ? 's' : ''}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hdr(
    String label, {
    int flex = 1,
    TextAlign align = TextAlign.left,
    bool isSortable = false,
    bool isSorted = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: isSortable ? onTap : null,
        child: Row(
          mainAxisAlignment: align == TextAlign.right
              ? MainAxisAlignment.end
              : (align == TextAlign.center
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start),
          children: [
            Text(
              label,
              textAlign: align,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isSorted ? _lightBlue : IaColors.mutedForeground,
              ),
            ),
            if (isSortable) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.sort_by_alpha,
                size: 12,
                color: isSorted ? _lightBlue : IaColors.mutedForeground.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Individual row — no GestureDetector wrapping to avoid
// double-firing with Checkbox.onChanged
// ─────────────────────────────────────────────────────────
class _ProductRow extends StatefulWidget {
  final int index;
  final Product product;
  final String? editedDescription;
  final bool isSelected;
  final String Function(double) formatPrice;
  final VoidCallback onToggle;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onAddSingle;

  const _ProductRow({
    super.key,
    required this.index,
    required this.product,
    this.editedDescription,
    required this.isSelected,
    required this.formatPrice,
    required this.onToggle,
    required this.onDescriptionChanged,
    required this.onAddSingle,
  });

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = _hovered || widget.isSelected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? _lightBlue.withOpacity(0.08)
              : (_hovered
                    ? IaColors.muted.withOpacity(0.4)
                    : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected
                ? _lightBlue.withOpacity(0.4)
                : (_hovered ? IaColors.border : Colors.transparent),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      widget.isSelected ? 0.04 : 0.02,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: SelectionArea(
          child: Row(
            children: [
              // Checkbox — the ONLY selection trigger (no wrapping GestureDetector)
              SizedBox(
                width: 44,
                child: Checkbox(
                  value: widget.isSelected,
                  onChanged: (_) => widget.onToggle(),
                  activeColor: _lightBlue,
                  side: BorderSide(
                    color: _lightBlue.withOpacity(0.5),
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Referencia
              Expanded(
                flex: 2,
                child: Text(
                  widget.product.referencia,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: IaColors.mutedForeground,
                  ),
                ),
              ),
              // Descripcion (Editable)
              Expanded(
                flex: 4,
                child: TextField(
                  controller: TextEditingController(
                    text: widget.editedDescription ?? widget.product.descripcion,
                  )..selection = TextSelection.fromPosition(
                      TextPosition(
                        offset: (widget.editedDescription ??
                                widget.product.descripcion)
                            .length,
                      ),
                    ),
                  onChanged: widget.onDescriptionChanged,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: IaColors.foreground,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              // Bodega
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: IaColors.muted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: IaColors.border),
                    ),
                    child: Text(
                      widget.product.bodega,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: IaColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // Disponible
              Expanded(
                flex: 1,
                child: Text(
                  widget.product.disponible.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: IaColors.mutedForeground,
                  ),
                ),
              ),
              // Precio
              Expanded(
                flex: 2,
                child: Text(
                  '\$ ${widget.formatPrice(widget.product.precioParti)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: IaColors.foreground,
                  ),
                ),
              ),
              // Precio + IVA
              Expanded(
                flex: 2,
                child: Text(
                  '\$ ${widget.formatPrice(widget.product.precioParti * (1 + widget.product.iva / 100))}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: _lightBlue.withOpacity(0.9),
                  ),
                ),
              ),
              // Quick single-add button
              SizedBox(
                width: 36,
                child: AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.15,
                  duration: const Duration(milliseconds: 160),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: _lightBlue,
                      size: 18,
                    ),
                    tooltip: 'Agregar solo este',
                    onPressed: widget.onAddSingle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
