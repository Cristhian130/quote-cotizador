import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../stock/insights/domain/stock_insight.dart';
import '../../../stock/shared/application/stock_providers.dart';
import '../../../stock/shared/domain/stock_data_state.dart';

const _blue = Color(0xFF458AC9);
const _darkBlue = Color(0xFF192D4D);
const _green = Color(0xFF1F8A5B);
const _orange = Color(0xFFD97706);
const _red = Color(0xFFC93C37);
const _muted = Color(0xFF667085);
const _text = Color(0xFF1F2937);
const _border = Color(0xFFDDE3EA);
const _surface = Color(0xFFF8FAFC);

class QuotePrioritySelection {
  final String reference;
  final Set<String> warehouses;

  const QuotePrioritySelection({
    required this.reference,
    required this.warehouses,
  });

  bool matches(String productReference, String productWarehouse) {
    if (productReference.trim().toUpperCase() !=
        reference.trim().toUpperCase()) {
      return false;
    }
    if (warehouses.isEmpty) return true;
    return warehouses.contains(productWarehouse.trim().toUpperCase());
  }
}

class StockAlertBanner extends ConsumerStatefulWidget {
  final String warehouse;
  final ValueChanged<QuotePrioritySelection>? onSelectPriority;

  const StockAlertBanner({
    super.key,
    required this.warehouse,
    this.onSelectPriority,
  });

  @override
  ConsumerState<StockAlertBanner> createState() => _StockAlertBannerState();
}

class _StockAlertBannerState extends ConsumerState<StockAlertBanner> {
  final Set<int> _dismissedSnapshotIds = {};
  Timer? _warehouseDebounce;
  List<StockInsight> _items = const [];
  StockDataOrigin? _origin;
  Object? _error;
  String _filter = 'all';
  bool _expanded = true;
  bool _hidden = false;
  bool _loading = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant StockAlertBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.warehouse.trim().toUpperCase() !=
        widget.warehouse.trim().toUpperCase()) {
      _warehouseDebounce?.cancel();
      _warehouseDebounce = Timer(const Duration(milliseconds: 450), _load);
    }
  }

  @override
  void dispose() {
    _warehouseDebounce?.cancel();
    super.dispose();
  }

  String get _warehouse => widget.warehouse.trim().toUpperCase();

  List<StockInsight> get _visibleItems {
    return _items.where((item) {
      if (_dismissedSnapshotIds.contains(item.snapshotId)) return false;
      if (_filter == 'all') return true;
      return item.commercialSuggestion == _filter;
    }).toList(growable: false);
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    final repository = ref.read(insightsRepositoryProvider);
    final filters = InsightFilters(
      warehouse: _warehouse,
      onlyAlerts: true,
      pageSize: 100,
    );
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final local = await repository.readLocal(filters);
      if (!mounted || generation != _loadGeneration) return;
      if (local.items.isNotEmpty) {
        setState(() {
          _items = _sort(local.items);
          _origin = StockDataOrigin.local;
          if (_filter != 'all' &&
              !_items.any(
                (item) => item.commercialSuggestion == _filter,
              )) {
            _filter = 'all';
          }
        });
      }
    } catch (_) {
      // The remote request still has a chance to refresh the panel.
    }

    try {
      final result = await repository.load(filters);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _items = _sort(result.data.items);
        _origin = result.origin;
        _dismissedSnapshotIds.clear();
        if (_filter != 'all' &&
            !_items.any((item) => item.commercialSuggestion == _filter)) {
          _filter = 'all';
        }
      });
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _error = error);
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  List<StockInsight> _sort(List<StockInsight> items) {
    final sorted = [...items];
    int priority(StockInsight item) => switch (item.commercialSuggestion) {
      'priorizar_venta' => 0,
      'aplicar_descuento' => 1,
      'trasladar_producto' => 2,
      _ => 3,
    };
    sorted.sort((a, b) {
      final byAction = priority(a).compareTo(priority(b));
      if (byAction != 0) return byAction;
      final byDays = b.daysWithoutSale.compareTo(a.daysWithoutSale);
      if (byDays != 0) return byDays;
      return a.reference.compareTo(b.reference);
    });
    return sorted;
  }

  void _hideAll() {
    setState(() => _hidden = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
        content: const Text('Las sugerencias de Smart Insights están ocultas.'),
        action: SnackBarAction(
          label: 'Volver a mostrar',
          onPressed: _restoreAll,
        ),
      ),
    );
  }

  void _restoreAll() {
    if (!mounted) return;
    setState(() => _hidden = false);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _dismissItem(StockInsight item) {
    setState(() => _dismissedSnapshotIds.add(item.snapshotId));
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Sugerencia de ${item.reference} descartada.'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            if (mounted) {
              setState(() => _dismissedSnapshotIds.remove(item.snapshotId));
            }
          },
        ),
      ),
    );
  }

  QuotePrioritySelection _selectionFor(StockInsight selected) {
    final warehouses = _items
        .where(
          (item) =>
              item.reference == selected.reference &&
              item.commercialSuggestion == selected.commercialSuggestion,
        )
        .map((item) => item.warehouse.trim().toUpperCase())
        .where((warehouse) => warehouse.isNotEmpty)
        .toSet();
    return QuotePrioritySelection(
      reference: selected.reference,
      warehouses: warehouses,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) return _HiddenInsightsNotice(onRestore: _restoreAll);

    final visible = _visibleItems;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: _blue, width: 3),
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BannerHeader(
            count: _items.length,
            warehouse: _warehouse,
            origin: _origin,
            expanded: _expanded,
            loading: _loading,
            onToggle: () => setState(() => _expanded = !_expanded),
            onRefresh: _loading ? null : _load,
            onClose: _hideAll,
          ),
          if (_expanded) ...[
            _FilterBar(
              selected: _filter,
              items: _items,
              onSelected: (value) => setState(() => _filter = value),
            ),
            if (_loading && _items.isNotEmpty)
              const LinearProgressIndicator(minHeight: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: _buildContent(visible),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(List<StockInsight> visible) {
    if (_loading && _items.isEmpty) {
      return const SizedBox(
        height: 74,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_items.isEmpty && _error != null) {
      return _BannerMessage(
        icon: LucideIcons.cloudOff,
        title: 'No fue posible cargar las prioridades',
        message: 'La API no respondió y aún no existen alertas locales.',
        actionLabel: 'Reintentar',
        onAction: _load,
      );
    }
    if (_items.isEmpty) {
      return const _BannerMessage(
        icon: LucideIcons.checkCircle2,
        title: 'Sin prioridades pendientes',
        message: 'No hay alertas comerciales para la bodega seleccionada.',
      );
    }
    if (visible.isEmpty) {
      return const _BannerMessage(
        icon: LucideIcons.filter,
        title: 'Sin resultados en este filtro',
        message: 'Selecciona otra prioridad comercial.',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: visible.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
      itemBuilder: (context, index) {
        final item = visible[index];
        return _PriorityRow(
          item: item,
          onSelect: widget.onSelectPriority == null
              ? null
              : () => widget.onSelectPriority!(_selectionFor(item)),
          onDismiss: () => _dismissItem(item),
        );
      },
    );
  }
}

class _HiddenInsightsNotice extends StatelessWidget {
  final VoidCallback onRestore;

  const _HiddenInsightsNotice({required this.onRestore});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.bell, size: 14, color: _muted),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Las sugerencias de Smart Insights están ocultas.',
              style: TextStyle(fontSize: 10.5, color: _muted),
            ),
          ),
          TextButton(
            onPressed: onRestore,
            child: const Text('Volver a mostrar'),
          ),
        ],
      ),
    );
  }
}

class _BannerHeader extends StatelessWidget {
  final int count;
  final String warehouse;
  final StockDataOrigin? origin;
  final bool expanded;
  final bool loading;
  final VoidCallback onToggle;
  final VoidCallback? onRefresh;
  final VoidCallback onClose;

  const _BannerHeader({
    required this.count,
    required this.warehouse,
    required this.origin,
    required this.expanded,
    required this.loading,
    required this.onToggle,
    required this.onRefresh,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final sourceLabel = origin == null
        ? null
        : origin == StockDataOrigin.local
        ? 'Datos locales'
        : 'Backend';
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.auto_awesome, size: 15, color: _blue),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SMART INSIGHTS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: _darkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count prioridades · ${warehouse.isEmpty ? 'Todas las bodegas' : 'Bodega $warehouse'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: _muted),
                ),
              ],
            ),
          ),
          if (sourceLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: (origin == StockDataOrigin.local ? _orange : _green)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                sourceLabel,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: origin == StockDataOrigin.local ? _orange : _green,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Actualizar prioridades',
            onPressed: onRefresh,
            visualDensity: VisualDensity.compact,
            icon: loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.refreshCw, size: 15),
          ),
          IconButton(
            tooltip: expanded ? 'Contraer' : 'Expandir',
            onPressed: onToggle,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16,
            ),
          ),
          IconButton(
            tooltip: 'Ocultar todas las sugerencias',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(LucideIcons.x, size: 16),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final List<StockInsight> items;
  final ValueChanged<String> onSelected;

  const _FilterBar({
    required this.selected,
    required this.items,
    required this.onSelected,
  });

  int _count(String value) => value == 'all'
      ? items.length
      : items.where((item) => item.commercialSuggestion == value).length;

  @override
  Widget build(BuildContext context) {
    const filters = <(String, String)>[
      ('all', 'Todas'),
      ('priorizar_venta', 'Priorizar venta'),
      ('aplicar_descuento', 'Aplicar descuento'),
      ('trasladar_producto', 'Trasladar'),
    ];
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 7),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: filters.where((entry) => _count(entry.$1) > 0).map((entry) {
          final active = selected == entry.$1;
          return ChoiceChip(
            selected: active,
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            label: Text('${entry.$2} (${_count(entry.$1)})'),
            labelStyle: TextStyle(
              fontSize: 10.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onSelected: (_) => onSelected(entry.$1),
          );
        }).toList(),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final StockInsight item;
  final VoidCallback? onSelect;
  final VoidCallback onDismiss;

  const _PriorityRow({
    required this.item,
    required this.onSelect,
    required this.onDismiss,
  });

  Color get _actionColor => switch (item.commercialSuggestion) {
    'priorizar_venta' => _green,
    'aplicar_descuento' => _orange,
    'trasladar_producto' => _blue,
    _ => _muted,
  };

  IconData get _actionIcon => switch (item.commercialSuggestion) {
    'priorizar_venta' => LucideIcons.trendingUp,
    'aplicar_descuento' => LucideIcons.badgePercent,
    'trasladar_producto' => LucideIcons.arrowLeftRight,
    _ => LucideIcons.alertTriangle,
  };

  String get _actionLabel => switch (item.commercialSuggestion) {
    'priorizar_venta' => 'Priorizar venta',
    'aplicar_descuento' => 'Aplicar descuento',
    'trasladar_producto' => 'Revisar traslado',
    _ => 'Revisión comercial',
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;
        final identity = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.reference,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.description,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: _muted),
            ),
          ],
        );
        final metrics = Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            _ValueChip(
              label: item.warehouse.isEmpty ? 'Sin bodega' : item.warehouse,
              color: _muted,
            ),
            _ValueChip(
              label: '${_number(item.availableStock)} disponibles',
              color: item.availableStock > 0 ? _green : _red,
            ),
            _ValueChip(
              label: item.classification.isEmpty
                  ? 'Sin clase'
                  : item.classification,
              color: const {'Z', 'ZZ'}.contains(item.classification)
                  ? _red
                  : _orange,
            ),
            _ValueChip(
              label: '${item.daysWithoutSale} d sin venta',
              color: item.daysWithoutSale >= 180 ? _red : _muted,
            ),
          ],
        );
        final action = FilledButton.icon(
          onPressed: onSelect,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 31),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: _actionColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            textStyle: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: Icon(_actionIcon, size: 13),
          label: Text(
            item.commercialSuggestion == 'priorizar_venta'
                ? 'Cotizar ahora'
                : 'Usar referencia',
          ),
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_actionIcon, size: 16, color: _actionColor),
                        const SizedBox(width: 8),
                        Expanded(child: identity),
                        IconButton(
                          tooltip: 'Descartar sugerencia',
                          onPressed: onDismiss,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(LucideIcons.x, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    metrics,
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _actionLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: _actionColor,
                            ),
                          ),
                        ),
                        action,
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _actionColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(_actionIcon, size: 15, color: _actionColor),
                    ),
                    const SizedBox(width: 9),
                    Expanded(flex: 3, child: identity),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: metrics),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      child: Text(
                        _actionLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _actionColor,
                        ),
                      ),
                    ),
                    action,
                    IconButton(
                      tooltip: 'Descartar sugerencia',
                      onPressed: onDismiss,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(LucideIcons.x, size: 14),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ValueChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _BannerMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _BannerMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: _muted),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 10.5, color: _muted),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
