import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';
import '../../insights/domain/stock_insight.dart';
import '../../shared/application/stock_providers.dart';
import '../../shared/domain/stock_data_state.dart';
import '../../shared/presentation/erp_stock_widgets.dart';
import '../../transfers/domain/transfer_suggestion.dart';
import '../../transfers/presentation/transfer_suggestions_panel.dart';
import '../domain/business_rule.dart';
import '../domain/rule_evaluation_filters.dart';
import 'business_rule_editor_dialog.dart';
import 'managed_rules_panel.dart';

enum _BusinessRulesSection { rules, evaluation, transfers }

class BusinessRulesView extends ConsumerStatefulWidget {
  const BusinessRulesView({super.key});

  @override
  ConsumerState<BusinessRulesView> createState() => _BusinessRulesViewState();
}

class _BusinessRulesViewState extends ConsumerState<BusinessRulesView> {
  final _minimumStock = TextEditingController();
  final _minimumDays = TextEditingController();
  final _transferReference = TextEditingController();
  final _transferWarehouse = TextEditingController();
  final _transferOperationCenter = TextEditingController();
  final _transferQuantity = TextEditingController();
  final _transferLimit = TextEditingController();
  String _companyId = '';
  String _city = '';
  List<BusinessRule> _rules = const [];
  List<StockInsight> _evaluation = const [];
  TransferSuggestionsResult? _transferSuggestions;
  TransferPreview? _transferPreview;
  final Set<String> _pendingIds = {};
  StockDataOrigin? _origin;
  DateTime? _syncedAt;
  Object? _error;
  bool _loading = false;
  bool _creating = false;
  bool _evaluating = false;
  bool _findingTransfers = false;
  bool _previewingTransfer = false;
  Object? _transferError;
  _BusinessRulesSection _section = _BusinessRulesSection.rules;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRules());
  }

  @override
  void dispose() {
    _minimumStock.dispose();
    _minimumDays.dispose();
    _transferReference.dispose();
    _transferWarehouse.dispose();
    _transferOperationCenter.dispose();
    _transferQuantity.dispose();
    _transferLimit.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    if (!mounted) return;
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
        _setEvaluationDefaults(result.data);
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setEvaluationDefaults(List<BusinessRule> rules) {
    if (_minimumStock.text.isEmpty) {
      final stockRule = _firstActive(
        rules,
        BusinessRuleCondition.highStockLowRotation,
      );
      _minimumStock.text = _number(stockRule?.threshold ?? 3);
    }
    if (_minimumDays.text.isEmpty) {
      final daysRule = _firstActive(
        rules,
        BusinessRuleCondition.inventoryAge,
      );
      _minimumDays.text = _number(daysRule?.threshold ?? 180);
    }
  }

  Future<void> _evaluate() async {
    final stock = double.tryParse(_minimumStock.text.trim());
    final daysValue = double.tryParse(_minimumDays.text.trim());
    if (stock == null || daysValue == null || stock < 0 || daysValue < 0) {
      _notify('Stock mínimo y días sin venta deben ser valores numéricos.');
      return;
    }
    setState(() {
      _evaluating = true;
      _error = null;
    });
    try {
      final page = await ref.read(rulesRepositoryProvider).evaluate(
        RuleEvaluationFilters(
          companyId: _companyId,
          city: _city,
          minimumStock: stock,
          minimumDaysWithoutSale: daysValue.round(),
        ),
      );
      if (mounted) setState(() => _evaluation = page.items);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
        _notify(_errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _evaluating = false);
    }
  }

  CityTransferRequest? _cityTransferRequest() {
    final reference = _transferReference.text.trim();
    final warehouse = _transferWarehouse.text.trim().toUpperCase();
    final operationCenter = _transferOperationCenter.text.trim();
    final quantityText = _transferQuantity.text.trim();
    final limitText = _transferLimit.text.trim();
    final quantity = quantityText.isEmpty ? null : int.tryParse(quantityText);
    final limit = limitText.isEmpty ? null : int.tryParse(limitText);
    if (_city.isEmpty) {
      _notify('Ciudad es obligatoria para consultar traslados.');
      return null;
    }
    if ((quantityText.isNotEmpty && (quantity == null || quantity <= 0)) ||
        (limitText.isNotEmpty && (limit == null || limit <= 0))) {
      _notify('Cantidad y límite deben ser números mayores que cero.');
      return null;
    }
    return CityTransferRequest(
      city: _city,
      reference: reference,
      companyId: _companyId,
      originWarehouse: warehouse,
      originOperationCenter: operationCenter,
      quantity: quantity,
      limit: limit,
    );
  }

  Future<void> _findTransferSuggestions() async {
    final request = _cityTransferRequest();
    if (request == null) return;
    setState(() {
      _findingTransfers = true;
      _transferError = null;
      _transferPreview = null;
    });
    try {
      final result = await ref
          .read(transfersRepositoryProvider)
          .findSuggestionsByCity(request);
      if (mounted) setState(() => _transferSuggestions = result);
    } catch (error) {
      if (mounted) {
        setState(() {
          _transferSuggestions = null;
          _transferError = error;
        });
        _notify(_errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _findingTransfers = false);
    }
  }

  Future<void> _previewTransfer() async {
    final request = _previewTransferRequest();
    if (request == null) return;
    setState(() {
      _previewingTransfer = true;
      _transferError = null;
    });
    try {
      final preview = await ref.read(transfersRepositoryProvider).preview(request);
      if (mounted) {
        setState(() => _transferPreview = preview);
        _notify('Preview de traslado generado.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _transferError = error);
        _notify(_errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _previewingTransfer = false);
    }
  }

  TransferRequest? _previewTransferRequest() {
    final reference = _transferReference.text.trim();
    final warehouse = _transferWarehouse.text.trim().toUpperCase();
    final operationCenter = _transferOperationCenter.text.trim();
    final quantityText = _transferQuantity.text.trim();
    final limitText = _transferLimit.text.trim();
    final quantity = quantityText.isEmpty ? 1 : int.tryParse(quantityText);
    final limit = limitText.isEmpty ? 50 : int.tryParse(limitText);
    if (reference.isEmpty || _companyId.isEmpty ||
        (warehouse.isEmpty && operationCenter.isEmpty)) {
      _notify('El preview requiere referencia, empresa y bodega o centro de origen.');
      return null;
    }
    if (quantity == null || quantity <= 0 || limit == null || limit <= 0) {
      _notify('Cantidad y límite deben ser números mayores que cero para el preview.');
      return null;
    }
    return TransferRequest(
      reference: reference,
      companyId: _companyId,
      originWarehouse: warehouse,
      originOperationCenter: operationCenter,
      quantity: quantity,
      limit: limit,
    );
  }

  Future<void> _openRuleEditor([BusinessRule? rule]) async {
    final draft = await showBusinessRuleEditorDialog(context, rule: rule);
    if (draft == null || !mounted) return;
    final pendingId = rule?.id ?? draft.id;
    setState(() {
      if (rule == null) _creating = true;
      _pendingIds.add(pendingId);
    });
    try {
      final repository = ref.read(rulesRepositoryProvider);
      final saved = rule == null
          ? await repository.create(draft)
          : await repository.update(draft);
      if (!mounted) return;
      setState(() => _upsert(saved, replacingId: rule?.id));
      _notify(rule == null ? 'Regla creada en el backend.' : 'Cambios guardados.');
    } catch (error) {
      if (mounted) _notify(_errorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _creating = false;
          _pendingIds.remove(pendingId);
        });
      }
    }
  }

  Future<void> _toggleRule(BusinessRule rule) async {
    setState(() => _pendingIds.add(rule.id));
    try {
      final updated = await ref.read(rulesRepositoryProvider).toggle(rule);
      if (!mounted) return;
      setState(() => _upsert(updated));
      _notify(updated.enabled ? 'Regla activada.' : 'Regla desactivada.');
    } catch (error) {
      if (mounted) _notify(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _pendingIds.remove(rule.id));
    }
  }

  Future<void> _deleteRule(BusinessRule rule) async {
    if (rule.isDefault) {
      _notify('Las reglas predeterminadas pueden editarse o desactivarse, pero no eliminarse.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const Text('Eliminar regla'),
        content: Text('Se eliminará “${rule.name}” de forma permanente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: stockDanger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _pendingIds.add(rule.id));
    try {
      await ref.read(rulesRepositoryProvider).delete(rule);
      if (!mounted) return;
      setState(() {
        _rules = _rules
            .where((item) => item.id != rule.id)
            .toList(growable: false);
      });
      _notify('Regla eliminada.');
    } catch (error) {
      if (mounted) _notify(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _pendingIds.remove(rule.id));
    }
  }

  void _upsert(BusinessRule rule, {String? replacingId}) {
    final index = _rules.indexWhere(
      (item) => item.id == (replacingId ?? rule.id),
    );
    if (index < 0) {
      _rules = [..._rules, rule];
      return;
    }
    final updated = [..._rules];
    updated[index] = rule;
    _rules = updated;
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ErpStockPage(
      title: 'Reglas de negocio',
      description: 'Condiciones dinámicas para alertas y acciones comerciales.',
      actions: [
        if (_origin != null) ...[
          StockOriginBadge(origin: _origin!, syncedAt: _syncedAt),
          const SizedBox(width: 8),
        ],
        ErpActionButton(
          label: 'Actualizar',
          icon: LucideIcons.refreshCw,
          onPressed: _loading ? null : _loadRules,
        ),
        const SizedBox(width: 8),
        if (_section == _BusinessRulesSection.rules)
          ErpActionButton(
            label: 'Nueva regla',
            icon: LucideIcons.plus,
            onPressed: _creating ? null : () => _openRuleEditor(),
            primary: true,
          )
        else if (_section == _BusinessRulesSection.transfers)
          ErpActionButton(
            label: 'Buscar sugerencias',
            icon: LucideIcons.search,
            onPressed: _findingTransfers ? null : _findTransferSuggestions,
            primary: true,
          )
        else
          ErpActionButton(
            label: 'Evaluar reglas',
            icon: LucideIcons.play,
            onPressed: _evaluating || _loading ? null : _evaluate,
            primary: true,
          ),
      ],
      filters: _toolbar(),
      child: _body(),
      ),
    );
  }

  Widget _toolbar() {
    final selector = SegmentedButton<_BusinessRulesSection>(
      segments: const [
        ButtonSegment(
          value: _BusinessRulesSection.rules,
          label: Text('Lista'),
          icon: Icon(LucideIcons.list, size: 14),
        ),
        ButtonSegment(
          value: _BusinessRulesSection.evaluation,
          label: Text('Evaluación'),
          icon: Icon(LucideIcons.play, size: 14),
        ),
        ButtonSegment(
          value: _BusinessRulesSection.transfers,
          label: Text('Traslados'),
          icon: Icon(LucideIcons.arrowRightLeft, size: 14),
        ),
      ],
      selected: {_section},
      showSelectedIcon: false,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, 32)),
        visualDensity: VisualDensity.compact,
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11.5)),
      ),
      onSelectionChanged: (selection) {
        setState(() => _section = selection.first);
      },
    );
    if (_section == _BusinessRulesSection.rules) {
      return Align(alignment: Alignment.centerLeft, child: selector);
    }
    if (_section == _BusinessRulesSection.transfers) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          selector,
          ErpTextFilter(
            label: 'Referencia',
            controller: _transferReference,
            width: 160,
          ),
          _EvaluationSelectFilter(
            label: 'Ciudad',
            value: _city,
            width: 150,
            options: const [
              _FilterChoice(value: 'BARRANQUILLA', label: 'BARRANQUILLA'),
              _FilterChoice(value: 'BOGOTA', label: 'BOGOTA'),
              _FilterChoice(value: 'BUCARAMANGA', label: 'BUCARAMANGA'),
              _FilterChoice(value: 'CALI', label: 'CALI'),
              _FilterChoice(value: 'CARTAGENA', label: 'CARTAGENA'),
              _FilterChoice(value: 'CUCUTA', label: 'CUCUTA'),
              _FilterChoice(value: 'DOSQUEBRADAS', label: 'DOSQUEBRADAS'),
              _FilterChoice(value: 'LA ESTRELLA', label: 'LA ESTRELLA'),
              _FilterChoice(value: 'MEDELLIN', label: 'MEDELLIN'),
              _FilterChoice(value: 'PASTO', label: 'PASTO'),
              _FilterChoice(value: 'PEREIRA', label: 'PEREIRA'),
              _FilterChoice(value: 'VILLAVICENCIO', label: 'VILLAVICENCIO'),
            ],
            onChanged: (value) => setState(() => _city = value),
          ),
          _EvaluationSelectFilter(
            label: 'Empresa',
            value: _companyId,
            width: 130,
            options: const [
              _FilterChoice(value: '1', label: 'Celeste'),
              _FilterChoice(value: '2', label: 'Nipon'),
              _FilterChoice(value: '3', label: 'Japon'),
              _FilterChoice(value: '4', label: 'Kimautos'),
            ],
            onChanged: (value) => setState(() => _companyId = value),
          ),
          ErpTextFilter(
            label: 'Bodega origen',
            controller: _transferWarehouse,
            width: 140,
          ),
          ErpTextFilter(
            label: 'Centro origen',
            controller: _transferOperationCenter,
            width: 135,
          ),
          ErpTextFilter(
            label: 'Cantidad opc.',
            controller: _transferQuantity,
            width: 95,
          ),
          ErpTextFilter(
            label: 'Límite opc.',
            controller: _transferLimit,
            width: 85,
          ),
          if (_findingTransfers)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        selector,
        _EvaluationSelectFilter(
          label: 'Empresa',
          value: _companyId,
          width: 130,
          options: const [
            _FilterChoice(value: '1', label: 'Celeste'),
            _FilterChoice(value: '2', label: 'Nipon'),
            _FilterChoice(value: '3', label: 'Japon'),
            _FilterChoice(value: '4', label: 'Kimautos'),
          ],
          onChanged: (value) => setState(() => _companyId = value),
        ),
        _EvaluationSelectFilter(
          label: 'Ciudad',
          value: _city,
          width: 150,
          options: const [
            _FilterChoice(value: 'BARRANQUILLA', label: 'BARRANQUILLA'),
            _FilterChoice(value: 'BOGOTA', label: 'BOGOTA'),
            _FilterChoice(value: 'BUCARAMANGA', label: 'BUCARAMANGA'),
            _FilterChoice(value: 'CALI', label: 'CALI'),
            _FilterChoice(value: 'CARTAGENA', label: 'CARTAGENA'),
            _FilterChoice(value: 'CUCUTA', label: 'CUCUTA'),
            _FilterChoice(value: 'DOSQUEBRADAS', label: 'DOSQUEBRADAS'),
            _FilterChoice(value: 'LA ESTRELLA', label: 'LA ESTRELLA'),
            _FilterChoice(value: 'MEDELLIN', label: 'MEDELLIN'),
            _FilterChoice(value: 'PASTO', label: 'PASTO'),
            _FilterChoice(value: 'PEREIRA', label: 'PEREIRA'),
            _FilterChoice(value: 'VILLAVICENCIO', label: 'VILLAVICENCIO'),
          ],
          onChanged: (value) => setState(() => _city = value),
        ),
        ErpTextFilter(
          label: 'Stock mínimo',
          controller: _minimumStock,
          width: 120,
        ),
        ErpTextFilter(
          label: 'Días sin venta',
          controller: _minimumDays,
          width: 130,
        ),
        if (_evaluating) ...[
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const Text(
            'Evaluando...',
            style: TextStyle(fontSize: 11, color: stockMuted),
          ),
        ],
      ],
    );
  }

  Widget _body() {
    if (_section == _BusinessRulesSection.rules) {
      if (_error != null && _rules.isEmpty && !_loading) {
        return ErpEmptyState(
          title: 'No fue posible cargar las reglas',
          message: _errorMessage(_error!),
          isError: true,
        );
      }
      return ManagedRulesPanel(
        rules: _rules,
        loading: _loading,
        pendingIds: _pendingIds,
        onEdit: (rule) => _openRuleEditor(rule),
        onToggle: _toggleRule,
        onDelete: _deleteRule,
      );
    }
    if (_section == _BusinessRulesSection.transfers) {
      return TransferSuggestionsPanel(
        result: _transferSuggestions,
        preview: _transferPreview,
        loading: _findingTransfers,
        previewing: _previewingTransfer,
        error: _transferError,
        onPreview: _previewTransfer,
      );
    }
    return _evaluationBody();
  }

  Widget _evaluationBody() {
    if (_loading && _rules.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final definitions = _EffectiveRulesPanel(rules: _rules);
        final results = _EvaluationPanel(
          items: _evaluation,
          error: _error,
          evaluating: _evaluating,
        );
        if (!wide) {
          return ListView(
            children: [
              SizedBox(height: 330, child: definitions),
              const Divider(height: 1),
              SizedBox(height: 500, child: results),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 410, child: definitions),
            const VerticalDivider(width: 1),
            Expanded(child: results),
          ],
        );
      },
    );
  }
}

class _FilterChoice {
  final String value;
  final String label;

  const _FilterChoice({required this.value, required this.label});
}

class _EvaluationSelectFilter extends StatelessWidget {
  final String label;
  final String value;
  final double width;
  final List<_FilterChoice> options;
  final ValueChanged<String> onChanged;

  const _EvaluationSelectFilter({
    required this.label,
    required this.value,
    required this.width,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    _FilterChoice? selected;
    for (final option in options) {
      if (option.value == value) {
        selected = option;
        break;
      }
    }
    return SizedBox(
      width: width,
      height: 34,
      child: PopupMenuButton<String>(
        tooltip: label,
        initialValue: value.isEmpty ? null : value,
        onSelected: onChanged,
        position: PopupMenuPosition.under,
        color: Colors.white,
        elevation: 8,
        padding: EdgeInsets.zero,
        offset: const Offset(0, 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: IaColors.border),
        ),
        itemBuilder: (context) => options
            .map(
              (option) => PopupMenuItem<String>(
                value: option.value,
                height: 36,
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      child: option.value == value
                          ? const Icon(
                              LucideIcons.check,
                              size: 14,
                              color: stockSuccess,
                            )
                          : null,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      option.label,
                      style: const TextStyle(fontSize: 11.5, color: stockText),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: IaColors.border),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.label ?? label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: selected == null ? stockMuted : stockText,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(LucideIcons.chevronDown, size: 14, color: stockMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EffectiveRulesPanel extends StatelessWidget {
  final List<BusinessRule> rules;

  const _EffectiveRulesPanel({required this.rules});

  @override
  Widget build(BuildContext context) {
    final active = rules.where((rule) => rule.enabled).toList(growable: false);
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelTitle(
            title: 'Reglas efectivas',
            subtitle: '${active.length} activas de ${rules.length}',
          ),
          Divider(height: 1, color: IaColors.border),
          if (active.isEmpty)
            const Expanded(
              child: ErpEmptyState(
                title: 'Sin reglas activas',
                message: 'Activa una regla antes de ejecutar la evaluación.',
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: active.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: IaColors.border,
                ),
                itemBuilder: (context, index) {
                  final rule = active[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: stockSuccess,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rule.name,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: stockText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_thresholdLabel(rule)} · ${_actionLabel(rule)}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: stockMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

  const _EvaluationPanel({
    required this.items,
    required this.error,
    required this.evaluating,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelTitle(
            title: 'Resultado de evaluación',
            subtitle: items.isEmpty
                ? 'Snapshot de rotación vigente'
                : '${items.length} alertas encontradas',
          ),
          Divider(height: 1, color: IaColors.border),
          if (items.isEmpty)
            Expanded(
              child: ErpEmptyState(
                title: error != null
                    ? 'No fue posible evaluar'
                    : evaluating
                    ? 'Evaluando reglas'
                    : 'Evaluación pendiente',
                message: error != null
                    ? _errorMessage(error!)
                    : 'Define los filtros y ejecuta la evaluación.',
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
                      ErpColumnLabel('Bodega'),
                      ErpColumnLabel('Stock', align: TextAlign.right),
                      ErpColumnLabel('Días sin venta', align: TextAlign.right),
                      ErpColumnLabel('Precio', align: TextAlign.right),
                      ErpColumnLabel('Últ. venta', align: TextAlign.right),
                      ErpColumnLabel('Sugerencia', flex: 2),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _EvaluationRow(item: items[index]),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: stockText,
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10.5, color: stockMuted)),
      ],
    ),
  );
}

class _EvaluationRow extends StatelessWidget {
  final StockInsight item;

  const _EvaluationRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _insightColor(item.colorHex);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.025),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9.5, color: stockMuted),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(item.warehouse, style: const TextStyle(fontSize: 11.5)),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _number(item.existingStock),
                  style: const TextStyle(fontSize: 11.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.daysWithoutSale} d',
                  style: TextStyle(fontSize: 11.5, color: color),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              item.price > 0 ? _currency(item.price) : '-',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: stockText),
            ),
          ),
          Expanded(
            child: Text(
              item.lastSaleCmr == null ? '-' : _shortDate(item.lastSaleCmr!),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: stockMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ErpStatusPill(
                label: _suggestion(item.commercialSuggestion),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BusinessRule? _firstActive(
  List<BusinessRule> rules,
  BusinessRuleCondition condition,
) {
  for (final rule in rules) {
    if (rule.enabled && rule.condition == condition) return rule;
  }
  return null;
}

String _thresholdLabel(BusinessRule rule) {
  final value = _number(rule.threshold);
  return switch (rule.condition) {
    BusinessRuleCondition.inventoryAge => '$value días',
    BusinessRuleCondition.highStockLowRotation => '$value unidades',
    BusinessRuleCondition.cityInventoryDifference => '$value%',
  };
}

String _actionLabel(BusinessRule rule) {
  final value = _number(rule.actionValue);
  return switch (rule.action) {
    BusinessRuleAction.applyDiscount => '$value% descuento',
    BusinessRuleAction.transferProduct => 'Trasladar $value unidades',
    BusinessRuleAction.prioritizeSale => 'Priorizar venta',
  };
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

Color _insightColor(String hex) {
  final value = hex.trim().replaceFirst('#', '');
  if (value.length != 6) return stockSuccess;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? stockSuccess : Color(0xFF000000 | parsed);
}

String _currency(double value) {
  final digits = value.round().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    groups.add(digits.substring(end - 3 < 0 ? 0 : end - 3, end));
  }
  return '\$ ${groups.reversed.join('.')}';
}

String _shortDate(DateTime value) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['details'];
      if (message != null && '$message'.trim().isNotEmpty) return '$message';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'No hay conexión con el backend. Se conservaron los datos locales.';
    }
  }
  return 'No fue posible completar la operación.';
}
