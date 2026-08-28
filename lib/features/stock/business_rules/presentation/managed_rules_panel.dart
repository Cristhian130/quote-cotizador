import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';
import '../../shared/presentation/erp_stock_widgets.dart';
import '../domain/business_rule.dart';

enum _RuleStatusFilter { all, active, inactive }

enum _RuleCommand { edit, toggle, delete }

class ManagedRulesPanel extends StatefulWidget {
  final List<BusinessRule> rules;
  final bool loading;
  final Set<String> pendingIds;
  final ValueChanged<BusinessRule> onEdit;
  final ValueChanged<BusinessRule> onToggle;
  final ValueChanged<BusinessRule> onDelete;

  const ManagedRulesPanel({
    super.key,
    required this.rules,
    required this.loading,
    required this.pendingIds,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<ManagedRulesPanel> createState() => _ManagedRulesPanelState();
}

class _ManagedRulesPanelState extends State<ManagedRulesPanel> {
  final _search = TextEditingController();
  _RuleStatusFilter _status = _RuleStatusFilter.all;
  BusinessRuleCondition? _condition;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<BusinessRule> get _visibleRules {
    final query = _search.text.trim().toLowerCase();
    return widget.rules.where((rule) {
      if (query.isNotEmpty &&
          !rule.name.toLowerCase().contains(query) &&
          !rule.id.toLowerCase().contains(query)) {
        return false;
      }
      if (_status == _RuleStatusFilter.active && !rule.enabled) return false;
      if (_status == _RuleStatusFilter.inactive && rule.enabled) return false;
      return _condition == null || rule.condition == _condition;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleRules;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ListToolbar(
            search: _search,
            status: _status,
            condition: _condition,
            visibleCount: visible.length,
            totalCount: widget.rules.length,
            onSearchChanged: (_) => setState(() {}),
            onStatusChanged: (value) => setState(() => _status = value),
            onConditionChanged: (value) =>
                setState(() => _condition = value),
          ),
          const Divider(height: 1, color: IaColors.border),
          if (widget.loading && widget.rules.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (visible.isEmpty)
            Expanded(
              child: ErpEmptyState(
                title: widget.rules.isEmpty
                    ? 'No hay reglas configuradas'
                    : 'No hay coincidencias',
                message: widget.rules.isEmpty
                    ? 'Usa Nueva regla para definir la primera condición.'
                    : 'Cambia la búsqueda o limpia los filtros aplicados.',
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  return Column(
                    children: [
                      if (!compact) const _RulesListHeader(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: IaColors.border,
                          ),
                          itemBuilder: (context, index) {
                            final rule = visible[index];
                            return _RuleListRow(
                              rule: rule,
                              compact: compact,
                              pending: widget.pendingIds.contains(rule.id),
                              onEdit: () => widget.onEdit(rule),
                              onToggle: () => widget.onToggle(rule),
                              onDelete: () => widget.onDelete(rule),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ListToolbar extends StatelessWidget {
  final TextEditingController search;
  final _RuleStatusFilter status;
  final BusinessRuleCondition? condition;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_RuleStatusFilter> onStatusChanged;
  final ValueChanged<BusinessRuleCondition?> onConditionChanged;

  const _ListToolbar({
    required this.search,
    required this.status,
    required this.condition,
    required this.visibleCount,
    required this.totalCount,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onConditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        final searchField = SizedBox(
          width: compact ? double.infinity : 300,
          height: 34,
          child: TextField(
            controller: search,
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 12, color: stockText),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o ID',
              hintStyle: const TextStyle(fontSize: 12, color: stockMuted),
              prefixIcon: const Icon(LucideIcons.search, size: 14),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 32,
              ),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        search.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(LucideIcons.x, size: 14),
                    ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 32,
              ),
              filled: true,
              fillColor: const Color(0xFFFAFBFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: IaColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: IaColors.primaryLight),
              ),
            ),
          ),
        );
        final commands = Wrap(
          spacing: 7,
          runSpacing: 7,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FilterMenu<_RuleStatusFilter>(
              label: _statusLabel(status),
              icon: LucideIcons.circleDot,
              value: status,
              options: const [
                (_RuleStatusFilter.all, 'Todos los estados'),
                (_RuleStatusFilter.active, 'Activas'),
                (_RuleStatusFilter.inactive, 'Inactivas'),
              ],
              onSelected: onStatusChanged,
            ),
            _FilterMenu<String>(
              label: condition == null
                  ? 'Todas las condiciones'
                  : _conditionLabel(condition!),
              icon: LucideIcons.listFilter,
              value: condition?.name ?? '',
              options: [
                const ('', 'Todas las condiciones'),
                ...BusinessRuleCondition.values.map(
                  (item) => (item.name, _conditionLabel(item)),
                ),
              ],
              onSelected: (value) {
                for (final item in BusinessRuleCondition.values) {
                  if (item.name == value) {
                    onConditionChanged(item);
                    return;
                  }
                }
                onConditionChanged(null);
              },
            ),
            Text(
              visibleCount == totalCount
                  ? '$totalCount registros'
                  : '$visibleCount de $totalCount',
              style: const TextStyle(fontSize: 10.5, color: stockMuted),
            ),
          ],
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchField,
                    const SizedBox(height: 8),
                    commands,
                  ],
                )
              : Row(
                  children: [
                    searchField,
                    const SizedBox(width: 10),
                    Expanded(child: commands),
                  ],
                ),
        );
      },
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onSelected;

  const _FilterMenu({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: label,
      initialValue: value,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: IaColors.border),
      ),
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<T>(
              value: option.$1,
              height: 36,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: option.$1 == value
                        ? const Icon(LucideIcons.check, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(option.$2, style: const TextStyle(fontSize: 11.5)),
                ],
              ),
            ),
          )
          .toList(growable: false),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: IaColors.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: stockMuted),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: stockText),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronDown, size: 12, color: stockMuted),
          ],
        ),
      ),
    );
  }
}

class _RulesListHeader extends StatelessWidget {
  const _RulesListHeader();

  @override
  Widget build(BuildContext context) => Container(
    height: 34,
    color: const Color(0xFFF3F4F6),
    padding: const EdgeInsets.only(left: 18, right: 8),
    child: const Row(
      children: [
        SizedBox(width: 18),
        Expanded(flex: 5, child: _ColumnLabel('Regla')),
        Expanded(flex: 3, child: _ColumnLabel('Condición')),
        Expanded(flex: 2, child: _ColumnLabel('Umbral')),
        Expanded(flex: 3, child: _ColumnLabel('Acción comercial')),
        SizedBox(width: 110, child: _ColumnLabel('Estado')),
        SizedBox(width: 40),
      ],
    ),
  );
}

class _ColumnLabel extends StatelessWidget {
  final String label;

  const _ColumnLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
    label,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      color: stockMuted,
    ),
  );
}

class _RuleListRow extends StatefulWidget {
  final BusinessRule rule;
  final bool compact;
  final bool pending;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _RuleListRow({
    required this.rule,
    required this.compact,
    required this.pending,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_RuleListRow> createState() => _RuleListRowState();
}

class _RuleListRowState extends State<_RuleListRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered ? const Color(0xFFF8FAFC) : Colors.white,
        child: InkWell(
          onTap: widget.pending ? null : widget.onEdit,
          child: widget.compact ? _compactRow() : _desktopRow(),
        ),
      ),
    );
  }

  Widget _desktopRow() {
    final rule = widget.rule;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.only(left: 18, right: 8, top: 8, bottom: 8),
      child: Row(
        children: [
          _RuleIndicator(enabled: rule.enabled),
          Expanded(flex: 5, child: _identity()),
          Expanded(
            flex: 3,
            child: Text(
              _conditionLabel(rule.condition),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: stockText),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _thresholdLabel(rule),
              style: const TextStyle(fontSize: 11.5, color: stockText),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _actionLabel(rule),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: stockText),
            ),
          ),
          SizedBox(width: 110, child: _status()),
          SizedBox(width: 40, child: _menu()),
        ],
      ),
    );
  }

  Widget _compactRow() {
    final rule = widget.rule;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 6, 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RuleIndicator(enabled: rule.enabled),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _identity(),
                const SizedBox(height: 7),
                Text(
                  '${_conditionLabel(rule.condition)} · ${_thresholdLabel(rule)}',
                  style: const TextStyle(fontSize: 10.5, color: stockMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  _actionLabel(rule),
                  style: const TextStyle(fontSize: 10.5, color: stockText),
                ),
                const SizedBox(height: 7),
                _status(),
              ],
            ),
          ),
          _menu(),
        ],
      ),
    );
  }

  Widget _identity() => Row(
    children: [
      Flexible(
        child: Text(
          widget.rule.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: widget.rule.enabled ? stockText : stockMuted,
          ),
        ),
      ),
      if (widget.rule.isDefault) ...[
        const SizedBox(width: 6),
        const Tooltip(
          message: 'Regla predeterminada del sistema',
          child: Icon(LucideIcons.lockKeyhole, size: 12, color: stockMuted),
        ),
      ],
      if (widget.pending) ...[
        const SizedBox(width: 8),
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ],
    ],
  );

  Widget _status() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.rule.enabled ? stockSuccess : const Color(0xFF98A2B3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        widget.rule.enabled ? 'Activa' : 'Inactiva',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: widget.rule.enabled ? stockSuccess : stockMuted,
        ),
      ),
    ],
  );

  Widget _menu() {
    if (widget.pending) return const SizedBox.shrink();
    return PopupMenuButton<_RuleCommand>(
      tooltip: 'Acciones',
      position: PopupMenuPosition.under,
      color: Colors.white,
      elevation: 8,
      padding: EdgeInsets.zero,
      icon: const Icon(LucideIcons.ellipsisVertical, size: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: IaColors.border),
      ),
      onSelected: (command) {
        switch (command) {
          case _RuleCommand.edit:
            widget.onEdit();
            break;
          case _RuleCommand.toggle:
            widget.onToggle();
            break;
          case _RuleCommand.delete:
            widget.onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _RuleCommand.edit,
          height: 36,
          child: _MenuCommand(icon: LucideIcons.pencil, label: 'Editar'),
        ),
        PopupMenuItem(
          value: _RuleCommand.toggle,
          height: 36,
          child: _MenuCommand(
            icon: widget.rule.enabled ? LucideIcons.pause : LucideIcons.play,
            label: widget.rule.enabled ? 'Desactivar' : 'Activar',
          ),
        ),
        if (!widget.rule.isDefault) ...[
          const PopupMenuDivider(height: 1),
          const PopupMenuItem(
            value: _RuleCommand.delete,
            height: 36,
            child: _MenuCommand(
              icon: LucideIcons.trash2,
              label: 'Eliminar',
              danger: true,
            ),
          ),
        ],
      ],
    );
  }
}

class _RuleIndicator extends StatelessWidget {
  final bool enabled;

  const _RuleIndicator({required this.enabled});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 18,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? stockSuccess : const Color(0xFFCBD0D8),
        ),
      ),
    ),
  );
}

class _MenuCommand extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;

  const _MenuCommand({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? stockDanger : stockText;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 9),
        Text(label, style: TextStyle(fontSize: 11.5, color: color)),
      ],
    );
  }
}

String _statusLabel(_RuleStatusFilter value) => switch (value) {
  _RuleStatusFilter.all => 'Todos los estados',
  _RuleStatusFilter.active => 'Activas',
  _RuleStatusFilter.inactive => 'Inactivas',
};

String _conditionLabel(BusinessRuleCondition value) => switch (value) {
  BusinessRuleCondition.inventoryAge => 'Días en inventario',
  BusinessRuleCondition.highStockLowRotation => 'Stock alto y baja rotación',
  BusinessRuleCondition.cityInventoryDifference => 'Diferencia entre ciudades',
};

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
    BusinessRuleAction.applyDiscount => 'Aplicar $value% de descuento',
    BusinessRuleAction.transferProduct => 'Trasladar $value unidades',
    BusinessRuleAction.prioritizeSale => 'Priorizar venta',
  };
}

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
