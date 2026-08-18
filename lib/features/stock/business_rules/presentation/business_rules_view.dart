import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../insights/domain/stock_insight.dart';
import '../../shared/application/stock_providers.dart';
import '../../shared/domain/stock_data_state.dart';
import '../../shared/presentation/erp_stock_widgets.dart';
import '../domain/alert_rules.dart';

class BusinessRulesView extends ConsumerStatefulWidget {
  const BusinessRulesView({super.key});

  @override
  ConsumerState<BusinessRulesView> createState() => _BusinessRulesViewState();
}

class _BusinessRulesViewState extends ConsumerState<BusinessRulesView> {
  final _company = TextEditingController();
  final _city = TextEditingController();
  final _minimumStock = TextEditingController();
  final _minimumDays = TextEditingController();
  AlertRules? _rules;
  List<StockInsight> _evaluation = const [];
  StockDataOrigin? _origin;
  DateTime? _syncedAt;
  Object? _error;
  bool _loading = false;
  bool _evaluating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRules());
  }

  @override
  void dispose() {
    _company.dispose();
    _city.dispose();
    _minimumStock.dispose();
    _minimumDays.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(rulesRepositoryProvider).load();
      if (!mounted) return;
      setState(() {
        _rules = result.data;
        _origin = result.origin;
        _syncedAt = result.syncedAt;
        if (_minimumStock.text.isEmpty) {
          _minimumStock.text = _number(result.data.minimumHighStock);
        }
        if (_minimumDays.text.isEmpty) {
          _minimumDays.text = '${result.data.minimumInventoryDays}';
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _evaluate() async {
    final stock = double.tryParse(_minimumStock.text.trim());
    final days = int.tryParse(_minimumDays.text.trim());
    if (stock == null || days == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock mínimo y días sin venta deben ser numéricos.')),
      );
      return;
    }
    setState(() {
      _evaluating = true;
      _error = null;
    });
    try {
      final page = await ref.read(rulesRepositoryProvider).evaluate(
        RuleEvaluationFilters(
          companyId: _company.text.trim(),
          city: _city.text.trim().toUpperCase(),
          minimumStock: stock,
          minimumDaysWithoutSale: days,
        ),
      );
      if (mounted) setState(() => _evaluation = page.items);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _evaluating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErpStockPage(
      title: 'Reglas de negocio',
      description:
          'Parámetros vigentes del backend y evaluación operativa de alertas comerciales.',
      actions: [
        if (_origin != null) ...[
          StockOriginBadge(origin: _origin!, syncedAt: _syncedAt),
          const SizedBox(width: 8),
        ],
        ErpActionButton(
          label: 'Sincronizar reglas',
          icon: LucideIcons.refreshCw,
          onPressed: _loading ? null : _loadRules,
        ),
        const SizedBox(width: 8),
        ErpActionButton(
          label: 'Evaluar reglas',
          icon: LucideIcons.play,
          onPressed: _evaluating || _rules == null ? null : _evaluate,
          primary: true,
        ),
      ],
      filters: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ErpTextFilter(label: 'Empresa', controller: _company, width: 100),
          ErpTextFilter(label: 'Ciudad', controller: _city, width: 140),
          ErpTextFilter(label: 'Stock mínimo', controller: _minimumStock, width: 120),
          ErpTextFilter(label: 'Días sin venta', controller: _minimumDays, width: 130),
          if (_evaluating) ...[
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            const Text('Evaluando snapshot...', style: TextStyle(fontSize: 11.5, color: stockMuted)),
          ],
        ],
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_rules == null && _loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_rules == null) {
      return const ErpEmptyState(
        title: 'No hay reglas disponibles',
        message: 'La API no respondió y aún no existe una copia local de las reglas.',
        isError: true,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final rules = _RulesDefinitionPanel(rules: _rules!);
        final results = _EvaluationPanel(
          items: _evaluation,
          error: _error,
          evaluating: _evaluating,
        );
        if (!wide) {
          return ListView(
            children: [
              SizedBox(height: 410, child: rules),
              const Divider(height: 1),
              SizedBox(height: 500, child: results),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 410, child: rules),
            const VerticalDivider(width: 1),
            Expanded(child: results),
          ],
        );
      },
    );
  }
}

class _RulesDefinitionPanel extends StatelessWidget {
  final AlertRules rules;

  const _RulesDefinitionPanel({required this.rules});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PanelTitle(
            title: 'Configuración efectiva',
            subtitle: 'Solo lectura · administrada por backend',
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              children: [
                _RuleLine(label: 'Inventario mínimo', value: '${rules.minimumInventoryDays} días'),
                _RuleLine(label: 'Stock alto desde', value: _number(rules.minimumHighStock)),
                _RuleLine(label: 'Ventas máximas 180d', value: _number(rules.maximumSales180Days)),
                _RuleLine(label: 'Clasificación baja', value: rules.lowRotationClassifications.join(', ')),
                _RuleLine(label: 'Subgrupos sin descuento', value: rules.noDiscountSubgroups.join(', ')),
                _RuleLine(label: 'Paginación', value: '${rules.recommendedPagination} · ${rules.defaultPageSize} por página'),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Text('SUGERENCIAS HABILITADAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: stockMuted)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: rules.suggestions
                        .map((item) => ErpStatusPill(label: _suggestion(item), color: stockSuccess))
                        .toList(),
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

class _EvaluationPanel extends StatelessWidget {
  final List<StockInsight> items;
  final Object? error;
  final bool evaluating;

  const _EvaluationPanel({required this.items, required this.error, required this.evaluating});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelTitle(
            title: 'Resultado de evaluación',
            subtitle: items.isEmpty ? 'Ejecuta las reglas sobre el snapshot actual' : '${items.length} alertas encontradas',
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            Expanded(
              child: ErpEmptyState(
                title: error != null ? 'No fue posible evaluar' : 'Evaluación pendiente',
                message: error != null
                    ? 'Esta acción necesita conexión con el backend. Revisa los filtros e inténtalo de nuevo.'
                    : 'Define empresa, ciudad y umbrales; luego usa Evaluar reglas.',
                isError: error != null,
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  const ErpTableHeader(
                    children: [
                      ErpColumnLabel('Referencia', flex: 2),
                      ErpColumnLabel('Bodega', flex: 1),
                      ErpColumnLabel('Stock', flex: 1, align: TextAlign.right),
                      ErpColumnLabel('Sin venta', flex: 1, align: TextAlign.right),
                      ErpColumnLabel('Sugerencia', flex: 2),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => _EvaluationRow(item: items[index]),
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

class _PanelTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PanelTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: stockText)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10.5, color: stockMuted)),
      ],
    ),
  );
}

class _RuleLine extends StatelessWidget {
  final String label;
  final String value;

  const _RuleLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 38),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, color: stockMuted))),
        const SizedBox(width: 12),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: stockText))),
      ],
    ),
  );
}

class _EvaluationRow extends StatelessWidget {
  final StockInsight item;

  const _EvaluationRow({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(item.reference, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
        Expanded(child: Text(item.warehouse, style: const TextStyle(fontSize: 11.5))),
        Expanded(child: Text(_number(item.existingStock), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5))),
        Expanded(child: Text('${item.daysWithoutSale} d', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11.5, color: stockDanger))),
        Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: ErpStatusPill(label: _suggestion(item.commercialSuggestion), color: stockDanger))),
      ],
    ),
  );
}

String _suggestion(String value) => switch (value) {
  'aplicar_descuento' => 'Aplicar descuento',
  'trasladar_producto' => 'Trasladar producto',
  'priorizar_venta' => 'Priorizar venta',
  _ => value.isEmpty ? 'Sin sugerencia' : value,
};

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
