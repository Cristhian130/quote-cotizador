import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../shared/application/stock_providers.dart';
import '../../shared/domain/stock_data_state.dart';
import '../../shared/presentation/erp_stock_widgets.dart';
import '../domain/inventory_item.dart';

class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});

  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  final _search = TextEditingController();
  final _company = TextEditingController();
  final _warehouse = TextEditingController();
  final _city = TextEditingController();
  final _operationCenter = TextEditingController();
  final _horizontalScroll = ScrollController();
  InventoryFilters _filters = const InventoryFilters();
  List<InventoryItem> _items = const [];
  StockDataOrigin? _origin;
  DateTime? _syncedAt;
  Object? _error;
  bool _loading = false;
  String _searchMode = 'Referencia';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _company.dispose();
    _warehouse.dispose();
    _city.dispose();
    _operationCenter.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  InventoryFilters get _currentFilters => _filters.copyWith(
    query: _search.text.trim(),
    companyId: _company.text.trim(),
    warehouse: _warehouse.text.trim().toUpperCase(),
    city: _city.text.trim().toUpperCase(),
    operationCenter: _operationCenter.text.trim(),
    searchByDescription: _searchMode == 'Descripción',
  );

  Future<void> _load() async {
    final repository = ref.read(inventoryRepositoryProvider);
    final filters = _currentFilters;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final local = await repository.readLocal(filters);
      if (!mounted) return;
      if (local.isNotEmpty) {
        setState(() {
          _items = local;
          _origin = StockDataOrigin.local;
        });
      }
    } catch (_) {
      // A failed local read must not prevent the remote refresh.
    }

    try {
      final result = await repository.load(filters);
      if (!mounted) return;
      setState(() {
        _items = result.data;
        _origin = result.origin;
        _syncedAt = result.syncedAt;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scheduleSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  @override
  Widget build(BuildContext context) {
    return ErpStockPage(
      title: 'Visor de inventario',
      description:
          'Inventario nacional ordenado por prioridad de marca, disponibilidad y ubicación.',
      actions: [
        if (_origin != null) ...[
          StockOriginBadge(origin: _origin!, syncedAt: _syncedAt),
          const SizedBox(width: 8),
        ],
        ErpActionButton(
          label: 'Sincronizar',
          icon: LucideIcons.refreshCw,
          onPressed: _loading ? null : _load,
          primary: true,
        ),
      ],
      filters: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: ErpSearchField(
              controller: _search,
              hint: 'Buscar referencia o descripción',
              onSubmitted: (_) => _load(),
              onChanged: _scheduleSearch,
            ),
          ),
          ErpSelectFilter(
            value: _searchMode,
            label: 'Buscar por',
            options: const ['Referencia', 'Descripción'],
            width: 125,
            onChanged: (value) {
              if (value == null || value.isEmpty) return;
              setState(() => _searchMode = value);
              _load();
            },
          ),
          ErpTextFilter(label: 'Empresa', controller: _company, width: 90),
          ErpTextFilter(label: 'Ciudad', controller: _city),
          ErpTextFilter(label: 'Bodega', controller: _warehouse, width: 110),
          ErpTextFilter(
            label: 'Centro operación',
            controller: _operationCenter,
            width: 145,
          ),
          SizedBox(
            height: 34,
            child: FilterChip(
              selected: _filters.onlyAvailable,
              showCheckmark: true,
              label: const Text('Solo disponibles'),
              labelStyle: const TextStyle(fontSize: 11.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onSelected: (value) {
                setState(() => _filters = _filters.copyWith(onlyAvailable: value));
                _load();
              },
            ),
          ),
          ErpActionButton(
            label: 'Aplicar filtros',
            icon: LucideIcons.filter,
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      child: Column(
        children: [
          _InventorySummary(
            count: _items.length,
            available: _items.fold(0, (sum, item) => sum + item.available),
            ambiguous: _items.where((item) => item.ambiguousWarehouse).length,
            loading: _loading,
          ),
          const Divider(height: 1),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_items.isEmpty && _error != null) {
      return const ErpEmptyState(
        title: 'No fue posible consultar el inventario',
        message:
            'La API no respondió y todavía no hay datos locales para estos filtros.',
        isError: true,
      );
    }
    if (_items.isEmpty) {
      return const ErpEmptyState(
        title: 'Sin resultados',
        message: 'Prueba otra referencia o amplía los filtros de inventario.',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _CompactInventoryRow(
              item: _items[index],
              onView: () => _showDetail(_items[index]),
            ),
          );
        }

        final condensed = constraints.maxWidth < 1080;
        final minimumWidth = condensed ? 840.0 : 1120.0;
        final tableWidth = constraints.maxWidth < minimumWidth
            ? minimumWidth
            : constraints.maxWidth;
        return Scrollbar(
          controller: _horizontalScroll,
          thumbVisibility: tableWidth > constraints.maxWidth,
          child: SingleChildScrollView(
            controller: _horizontalScroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  ErpTableHeader(
                    children: [
                      const ErpColumnLabel('Referencia', flex: 2),
                      const ErpColumnLabel('Descripción', flex: 4),
                      const ErpColumnLabel('Bodega / Ciudad', flex: 2),
                      if (!condensed)
                        const ErpColumnLabel(
                          'Existencia',
                          flex: 1,
                          align: TextAlign.right,
                        ),
                      const ErpColumnLabel(
                        'Disponible',
                        flex: 1,
                        align: TextAlign.right,
                      ),
                      const ErpColumnLabel('Marca / Prioridad', flex: 2),
                      const ErpColumnLabel('Descuento', flex: 1),
                      const ErpColumnLabel(
                        'Acciones',
                        flex: 1,
                        align: TextAlign.right,
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => _InventoryRow(
                        item: _items[index],
                        condensed: condensed,
                        onView: () => _showDetail(_items[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetail(InventoryItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.reference, style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description),
              const SizedBox(height: 16),
              _DetailLine('Bodega', '${item.warehouse} · ${item.city}'),
              _DetailLine('Empresa / C.O.', '${item.companyId} · ${item.operationCenter}'),
              _DetailLine('Ubicación', item.location.isEmpty ? 'Sin dato' : item.location),
              _DetailLine('Stock', '${_number(item.stock)} existente · ${_number(item.available)} disponible'),
              _DetailLine('Marca', '${item.brandDescription} · prioridad ${item.brandPriority}'),
              _DetailLine('Subgrupo', item.subgroupCode.isEmpty ? 'Sin dato' : item.subgroupCode),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  final int count;
  final double available;
  final int ambiguous;
  final bool loading;

  const _InventorySummary({
    required this.count,
    required this.available,
    required this.ambiguous,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$count resultados', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
          Text('${_number(available)} unidades disponibles', style: const TextStyle(fontSize: 11.5, color: stockSuccess)),
          if (ambiguous > 0) ...[
            Text('$ambiguous bodegas ambiguas', style: const TextStyle(fontSize: 11.5, color: stockWarning)),
          ],
          if (loading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final InventoryItem item;
  final bool condensed;
  final VoidCallback onView;

  const _InventoryRow({
    required this.item,
    required this.condensed,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final availableColor = item.available > 0 ? stockSuccess : stockDanger;
    return Container(
      height: 54,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.reference, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 4, child: Text(item.description, style: const TextStyle(fontSize: 11.5), overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.warehouse, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                Text(item.city.isEmpty ? 'Sin ciudad' : item.city, style: const TextStyle(fontSize: 10.5, color: stockMuted)),
              ],
            ),
          ),
          if (!condensed)
            Expanded(flex: 1, child: Text(_number(item.stock), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5))),
          Expanded(flex: 1, child: Text(_number(item.available), textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: availableColor))),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.brandDescription.isEmpty ? 'Sin marca' : item.brandDescription, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                Text('Prioridad ${item.brandPriority}', style: const TextStyle(fontSize: 10.5, color: stockMuted)),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ErpStatusPill(
                label: item.allowsDiscount ? 'Aplica' : 'Bloqueado',
                color: item.allowsDiscount ? stockSuccess : stockWarning,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Ver detalle',
                onPressed: onView,
                icon: const Icon(LucideIcons.externalLink, size: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactInventoryRow extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onView;

  const _CompactInventoryRow({required this.item, required this.onView});

  @override
  Widget build(BuildContext context) {
    final availableColor = item.available > 0 ? stockSuccess : stockDanger;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.reference,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: stockText),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${item.warehouse} · ${item.city}',
                      style: const TextStyle(fontSize: 10.5, color: stockMuted),
                    ),
                    Text(
                      '${_number(item.available)} disponibles',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: availableColor,
                      ),
                    ),
                    ErpStatusPill(
                      label: item.allowsDiscount ? 'Descuento' : 'Sin descuento',
                      color: item.allowsDiscount ? stockSuccess : stockWarning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ver detalle',
            onPressed: onView,
            icon: const Icon(LucideIcons.externalLink, size: 16),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 11.5, color: stockMuted))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11.5, color: stockText))),
      ],
    ),
  );
}

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
