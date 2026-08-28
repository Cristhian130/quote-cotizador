import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../shared/application/stock_providers.dart';
import '../../shared/domain/stock_data_state.dart';
import '../../shared/presentation/erp_stock_widgets.dart';
import '../domain/stock_insight.dart';

class SmartInsightsView extends ConsumerStatefulWidget {
  const SmartInsightsView({super.key});

  @override
  ConsumerState<SmartInsightsView> createState() => _SmartInsightsViewState();
}

class _SmartInsightsViewState extends ConsumerState<SmartInsightsView> {
  final _search = TextEditingController();
  final _company = TextEditingController();
  final _city = TextEditingController();
  final _warehouse = TextEditingController();
  final _horizontalScroll = ScrollController();
  InsightFilters _filters = const InsightFilters();
  List<StockInsight> _items = const [];
  StockDataOrigin? _origin;
  DateTime? _syncedAt;
  int? _nextCursor;
  int? _total;
  Object? _error;
  bool _loading = false;
  String _activeView = 'Todos';
  String _searchMode = 'Referencia';
  Timer? _debounce;

  static const _views = ['Todos', 'Alertas', 'A / AA', 'Z / ZZ', 'Sin venta'];

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
    _city.dispose();
    _warehouse.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  InsightFilters _effectiveFilters({int? cursor}) {
    var classification = _filters.classification;
    var onlyAlerts = false;
    int? minimumDays = _filters.minimumDaysWithoutSale;
    if (_activeView == 'Alertas') onlyAlerts = true;
    if (_activeView == 'A / AA' || _activeView == 'Z / ZZ') {
      classification = '';
    }
    if (_activeView == 'Sin venta') minimumDays = minimumDays ?? 180;
    return _filters.copyWith(
      query: _search.text.trim(),
      companyId: _company.text.trim(),
      city: _city.text.trim().toUpperCase(),
      warehouse: _warehouse.text.trim().toUpperCase(),
      searchByDescription: _searchMode == 'Descripción',
      classification: classification,
      minimumDaysWithoutSale: minimumDays,
      onlyAlerts: onlyAlerts,
      cursor: cursor,
      clearCursor: cursor == null,
    );
  }

  Future<void> _load({bool append = false}) async {
    final repository = ref.read(insightsRepositoryProvider);
    final filters = _effectiveFilters(cursor: append ? _nextCursor : null);
    setState(() {
      _loading = true;
      _error = null;
    });

    if (!append) {
      try {
        final local = await repository.readLocal(filters);
        if (!mounted) return;
        if (local.items.isNotEmpty) {
          setState(() {
            _items = _applyCompoundView(local.items);
            _origin = StockDataOrigin.local;
          });
        }
      } catch (_) {
        // A failed local read must not prevent the remote refresh.
      }
    }

    try {
      final result = await repository.load(filters);
      if (!mounted) return;
      setState(() {
        final received = _applyCompoundView(result.data.items);
        _items = append ? [..._items, ...received] : received;
        _origin = result.origin;
        _syncedAt = result.syncedAt;
        _nextCursor = result.data.nextCursor;
        _total = const {'A / AA', 'Z / ZZ'}.contains(_activeView)
            ? null
            : result.data.total;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<StockInsight> _applyCompoundView(List<StockInsight> items) {
    if (_activeView == 'A / AA') {
      return items.where((item) => const {'A', 'AA'}.contains(item.classification)).toList();
    }
    if (_activeView == 'Z / ZZ') {
      return items.where((item) => const {'Z', 'ZZ'}.contains(item.classification)).toList();
    }
    return items;
  }

  void _scheduleSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  @override
  Widget build(BuildContext context) {
    return ErpStockPage(
      title: 'Smart Insights',
      description:
          'Clasificación, rotación y sugerencias comerciales sobre el snapshot vigente.',
      actions: [
        if (_origin != null) ...[
          StockOriginBadge(origin: _origin!, syncedAt: _syncedAt),
          const SizedBox(width: 8),
        ],
        ErpActionButton(
          label: 'Actualizar',
          icon: LucideIcons.refreshCw,
          onPressed: _loading ? null : _load,
          primary: true,
        ),
      ],
      filters: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _views.map((view) {
              final selected = view == _activeView;
              return ChoiceChip(
                selected: selected,
                label: Text(view),
                labelStyle: const TextStyle(fontSize: 11.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onSelected: (_) {
                  setState(() => _activeView = view);
                  _load();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 250,
                child: ErpSearchField(
                  controller: _search,
                  hint: 'Buscar referencia o descripción',
                  onChanged: _scheduleSearch,
                  onSubmitted: (_) => _load(),
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
              ErpSelectFilter(
                value: _filters.frequency,
                label: 'Frecuencia',
                options: const ['ALTA', 'MEDIA', 'BAJA'],
                onChanged: (value) {
                  setState(() => _filters = _filters.copyWith(frequency: value ?? ''));
                  _load();
                },
              ),
              ErpSelectFilter(
                value: _filters.suggestion,
                label: 'Sugerencia',
                width: 170,
                options: const [
                  'aplicar_descuento',
                  'trasladar_producto',
                  'priorizar_venta',
                ],
                onChanged: (value) {
                  setState(() => _filters = _filters.copyWith(suggestion: value ?? ''));
                  _load();
                },
              ),
              ErpActionButton(
                label: 'Aplicar filtros',
                icon: LucideIcons.filter,
                onPressed: _loading ? null : _load,
              ),
            ],
          ),
        ],
      ),
      child: Column(
        children: [
          _InsightSummary(items: _items, total: _total, loading: _loading),
          const Divider(height: 1),
          Expanded(child: _buildResults()),
          if (_items.isNotEmpty)
            _PaginationBar(
              visibleCount: _items.length,
              total: _total,
              canLoadMore: _nextCursor != null,
              loading: _loading,
              onLoadMore: () => _load(append: true),
            ),
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
        title: 'No hay datos de rotación disponibles',
        message: 'La API no respondió y SQLite no tiene un snapshot para estos filtros.',
        isError: true,
      );
    }
    if (_items.isEmpty) {
      return const ErpEmptyState(
        title: 'Sin productos en esta vista',
        message: 'Cambia la clasificación o amplía los filtros.',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _CompactInsightRow(item: _items[index]),
          );
        }

        final condensed = constraints.maxWidth < 1180;
        final minimumWidth = condensed ? 900.0 : 1220.0;
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
                      const ErpColumnLabel('Clase', flex: 1),
                      if (!condensed)
                        const ErpColumnLabel('Frecuencia', flex: 1),
                      const ErpColumnLabel(
                        'Stock',
                        flex: 1,
                        align: TextAlign.right,
                      ),
                      if (!condensed)
                        const ErpColumnLabel(
                          'Ventas 180d',
                          flex: 1,
                          align: TextAlign.right,
                        ),
                      const ErpColumnLabel(
                        'Sin venta',
                        flex: 1,
                        align: TextAlign.right,
                      ),
                      const ErpColumnLabel(
                        'Rotación',
                        flex: 1,
                        align: TextAlign.right,
                      ),
                      const ErpColumnLabel('Sugerencia', flex: 2),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => _InsightRow(
                        item: _items[index],
                        condensed: condensed,
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
}

class _InsightSummary extends StatelessWidget {
  final List<StockInsight> items;
  final int? total;
  final bool loading;

  const _InsightSummary({required this.items, required this.total, required this.loading});

  @override
  Widget build(BuildContext context) {
    final alerts = items.where((item) => item.highStockLowRotation).length;
    final actionable = items.where((item) => item.commercialSuggestion.isNotEmpty).length;
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${total ?? items.length} productos', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
          Text('$alerts alertas visibles', style: TextStyle(fontSize: 11.5, color: alerts > 0 ? stockDanger : stockMuted)),
          Text('$actionable con sugerencia', style: const TextStyle(fontSize: 11.5, color: stockSuccess)),
          if (loading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final StockInsight item;
  final bool condensed;

  const _InsightRow({required this.item, required this.condensed});

  @override
  Widget build(BuildContext context) {
    final classColor = const {'Z', 'ZZ'}.contains(item.classification)
        ? stockDanger
        : const {'A', 'AA'}.contains(item.classification)
        ? stockSuccess
        : stockWarning;
    return Container(
      height: 54,
      color: item.highStockLowRotation
          ? stockDanger.withValues(alpha: 0.025)
          : Colors.white,
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
          Expanded(child: Align(alignment: Alignment.centerLeft, child: ErpStatusPill(label: item.classification.isEmpty ? 'N/D' : item.classification, color: classColor))),
          if (!condensed)
            Expanded(child: Text(item.frequency.isEmpty ? 'N/D' : item.frequency, style: const TextStyle(fontSize: 11))),
          Expanded(child: Text(_number(item.existingStock), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5))),
          if (!condensed)
            Expanded(child: Text(_number(item.sales180Days), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5))),
          Expanded(child: Text('${item.daysWithoutSale} d', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, color: item.daysWithoutSale >= 180 ? stockDanger : stockText))),
          Expanded(child: Text(item.rotation.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ErpStatusPill(
                label: _suggestionLabel(item.commercialSuggestion),
                color: item.highStockLowRotation ? stockDanger : stockSuccess,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactInsightRow extends StatelessWidget {
  final StockInsight item;

  const _CompactInsightRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final classColor = const {'Z', 'ZZ'}.contains(item.classification)
        ? stockDanger
        : const {'A', 'AA'}.contains(item.classification)
        ? stockSuccess
        : stockWarning;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.reference,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ErpStatusPill(
                label: item.classification.isEmpty
                    ? 'N/D'
                    : item.classification,
                color: classColor,
              ),
            ],
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
                'Stock ${_number(item.existingStock)}',
                style: const TextStyle(fontSize: 10.5, color: stockText),
              ),
              Text(
                '${item.daysWithoutSale} d sin venta',
                style: TextStyle(
                  fontSize: 10.5,
                  color: item.daysWithoutSale >= 180
                      ? stockDanger
                      : stockMuted,
                ),
              ),
              ErpStatusPill(
                label: _suggestionLabel(item.commercialSuggestion),
                color: item.highStockLowRotation
                    ? stockDanger
                    : stockSuccess,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int visibleCount;
  final int? total;
  final bool canLoadMore;
  final bool loading;
  final VoidCallback onLoadMore;

  const _PaginationBar({
    required this.visibleCount,
    required this.total,
    required this.canLoadMore,
    required this.loading,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 42,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text('Mostrando $visibleCount${total == null ? '' : ' de $total'}', style: const TextStyle(fontSize: 11, color: stockMuted)),
        const Spacer(),
        TextButton.icon(
          onPressed: canLoadMore && !loading ? onLoadMore : null,
          icon: const Icon(LucideIcons.chevronDown, size: 14),
          label: Text(canLoadMore ? 'Cargar más' : 'Fin de resultados'),
        ),
      ],
    ),
  );
}

String _suggestionLabel(String value) {
  return switch (value) {
    'aplicar_descuento' => 'Aplicar descuento',
    'trasladar_producto' => 'Trasladar producto',
    'priorizar_venta' => 'Priorizar venta',
    _ => value.isEmpty ? 'Sin sugerencia' : value,
  };
}

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
