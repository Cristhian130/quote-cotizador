import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';
import '../../shared/presentation/erp_stock_widgets.dart';
import '../domain/business_rule.dart';

Future<BusinessRule?> showBusinessRuleEditorDialog(
  BuildContext context, {
  BusinessRule? rule,
}) {
  return showDialog<BusinessRule>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.48),
    builder: (_) => _BusinessRuleEditorDialog(rule: rule),
  );
}

class _BusinessRuleEditorDialog extends StatefulWidget {
  final BusinessRule? rule;

  const _BusinessRuleEditorDialog({this.rule});

  @override
  State<_BusinessRuleEditorDialog> createState() =>
      _BusinessRuleEditorDialogState();
}

class _BusinessRuleEditorDialogState
    extends State<_BusinessRuleEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _threshold;
  late final TextEditingController _actionValue;
  late BusinessRuleCondition _condition;
  late BusinessRuleAction _action;
  late bool _enabled;

  bool get _editing => widget.rule != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _name = TextEditingController(text: rule?.name ?? '');
    _threshold = TextEditingController(
      text: rule == null ? '90' : _number(rule.threshold),
    );
    _actionValue = TextEditingController(
      text: rule == null ? '10' : _number(rule.actionValue),
    );
    _condition = rule?.condition ?? BusinessRuleCondition.inventoryAge;
    _action = rule?.action ?? BusinessRuleAction.applyDiscount;
    _enabled = rule?.enabled ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _threshold.dispose();
    _actionValue.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final previous = widget.rule;
    Navigator.of(context).pop(
      BusinessRule(
        id: previous?.id ?? 'pending-${now.microsecondsSinceEpoch}',
        name: _name.text.trim(),
        condition: _condition,
        threshold: double.parse(_threshold.text.trim()),
        action: _action,
        actionValue: _action == BusinessRuleAction.prioritizeSale
            ? 0
            : double.parse(_actionValue.text.trim()),
        enabled: _enabled,
        isDefault: previous?.isDefault ?? false,
        createdAt: previous?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: screen.height - 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const Divider(height: 1, color: IaColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) => _form(
                      compact: constraints.maxWidth < 540,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: IaColors.border),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    constraints: const BoxConstraints(minHeight: 64),
    padding: const EdgeInsets.fromLTRB(22, 13, 10, 13),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _editing ? widget.rule!.name : 'Nueva regla de negocio',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: stockText,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _enabled ? stockSuccess : const Color(0xFF98A2B3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _editing
                          ? '${widget.rule!.id} · ${widget.rule!.isDefault ? 'Regla del sistema' : 'Regla personalizada'}'
                          : 'Nuevo registro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: stockMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.x, size: 17),
        ),
      ],
    ),
  );

  Widget _form({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('DETALLES'),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Nombre',
          required: true,
          child: TextFormField(
            controller: _name,
            autofocus: !_editing,
            style: const TextStyle(fontSize: 12.5, color: stockText),
            decoration: _inputDecoration('Ej. Inventario inmovilizado Bogotá'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'El nombre es obligatorio.'
                : null,
          ),
        ),
        const SizedBox(height: 16),
        if (compact) ...[
          _conditionField(),
          const SizedBox(height: 16),
          _thresholdField(),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _conditionField()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _thresholdField()),
            ],
          ),
        const SizedBox(height: 24),
        const _SectionLabel('ACCIÓN COMERCIAL'),
        const SizedBox(height: 12),
        if (compact) ...[
          _actionField(),
          if (_action != BusinessRuleAction.prioritizeSale) ...[
            const SizedBox(height: 16),
            _actionValueField(),
          ],
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _actionField()),
              if (_action != BusinessRuleAction.prioritizeSale) ...[
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _actionValueField()),
              ],
            ],
          ),
        const SizedBox(height: 22),
        InkWell(
          onTap: () => setState(() => _enabled = !_enabled),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _enabled,
                    onChanged: (value) =>
                        setState(() => _enabled = value ?? false),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Regla activa',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: stockText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _conditionField() => _LabeledField(
    label: 'Tipo de condición',
    required: true,
    child: _ErpChoiceField<BusinessRuleCondition>(
      value: _condition,
      options: BusinessRuleCondition.values
          .map(
            (value) => _ChoiceOption(
              value: value,
              label: _conditionLabel(value),
              description: _conditionDescription(value),
            ),
          )
          .toList(growable: false),
      onChanged: (value) => setState(() => _condition = value),
    ),
  );

  Widget _thresholdField() => _LabeledField(
    label: 'Umbral',
    required: true,
    suffix: _thresholdUnit(_condition),
    child: TextFormField(
      controller: _threshold,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 12.5, color: stockText),
      decoration: _inputDecoration('0'),
      validator: _positiveNumber,
    ),
  );

  Widget _actionField() => _LabeledField(
    label: 'Acción sugerida',
    required: true,
    child: _ErpChoiceField<BusinessRuleAction>(
      value: _action,
      options: BusinessRuleAction.values
          .map(
            (value) => _ChoiceOption(
              value: value,
              label: _actionLabel(value),
              description: _actionDescription(value),
            ),
          )
          .toList(growable: false),
      onChanged: (value) => setState(() => _action = value),
    ),
  );

  Widget _actionValueField() => _LabeledField(
    label: _action == BusinessRuleAction.applyDiscount
        ? 'Valor del descuento'
        : 'Cantidad a trasladar',
    required: true,
    suffix: _action == BusinessRuleAction.applyDiscount ? '%' : 'unidades',
    child: TextFormField(
      controller: _actionValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 12.5, color: stockText),
      decoration: _inputDecoration('0'),
      validator: _positiveNumber,
    ),
  );

  Widget _footer() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(_editing ? 'Guardar' : 'Crear regla'),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: stockMuted,
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(child: Divider(height: 1, color: IaColors.border)),
    ],
  );
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;
  final String? suffix;

  const _LabeledField({
    required this.label,
    required this.child,
    this.required = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: stockMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (required)
            const Text(' *', style: TextStyle(color: stockDanger, fontSize: 11)),
          if (suffix != null) ...[
            const Spacer(),
            Text(
              suffix!,
              style: const TextStyle(fontSize: 9.5, color: stockMuted),
            ),
          ],
        ],
      ),
      const SizedBox(height: 6),
      child,
    ],
  );
}

class _ChoiceOption<T> {
  final T value;
  final String label;
  final String description;

  const _ChoiceOption({
    required this.value,
    required this.label,
    required this.description,
  });
}

class _ErpChoiceField<T> extends StatelessWidget {
  final T value;
  final List<_ChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  const _ErpChoiceField({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = options.firstWhere((option) => option.value == value);
    final menuWidth = (MediaQuery.sizeOf(context).width - 64)
        .clamp(240.0, 360.0)
        .toDouble();
    return PopupMenuButton<T>(
      tooltip: selected.label,
      initialValue: value,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      color: Colors.white,
      elevation: 10,
      offset: const Offset(0, 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: IaColors.border),
      ),
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<T>(
              value: option.value,
              height: 52,
              child: SizedBox(
                width: menuWidth,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: option.value == value
                          ? const Icon(
                              LucideIcons.check,
                              size: 14,
                              color: stockSuccess,
                            )
                          : null,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: stockText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: stockMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: IaColors.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: stockText),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronDown, size: 14, color: stockMuted),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
  isDense: true,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(color: IaColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(color: IaColors.primaryLight),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(color: stockDanger),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: const BorderSide(color: stockDanger),
  ),
);

String? _positiveNumber(String? value) {
  final parsed = double.tryParse(value?.trim() ?? '');
  return parsed == null || parsed <= 0 ? 'Ingresa un valor mayor que cero.' : null;
}

String _conditionLabel(BusinessRuleCondition value) => switch (value) {
  BusinessRuleCondition.inventoryAge => 'Días en inventario',
  BusinessRuleCondition.highStockLowRotation => 'Stock alto y baja rotación',
  BusinessRuleCondition.cityInventoryDifference => 'Diferencia entre ciudades',
};

String _conditionDescription(BusinessRuleCondition value) => switch (value) {
  BusinessRuleCondition.inventoryAge => 'Antigüedad sin movimiento comercial',
  BusinessRuleCondition.highStockLowRotation => 'Exceso de unidades con baja salida',
  BusinessRuleCondition.cityInventoryDifference => 'Desbalance porcentual entre bodegas',
};

String _thresholdUnit(BusinessRuleCondition value) => switch (value) {
  BusinessRuleCondition.inventoryAge => 'días',
  BusinessRuleCondition.highStockLowRotation => 'unidades',
  BusinessRuleCondition.cityInventoryDifference => '% de diferencia',
};

String _actionLabel(BusinessRuleAction value) => switch (value) {
  BusinessRuleAction.applyDiscount => 'Aplicar descuento',
  BusinessRuleAction.transferProduct => 'Trasladar producto',
  BusinessRuleAction.prioritizeSale => 'Priorizar venta',
};

String _actionDescription(BusinessRuleAction value) => switch (value) {
  BusinessRuleAction.applyDiscount => 'Sugiere un porcentaje comercial',
  BusinessRuleAction.transferProduct => 'Propone unidades para traslado',
  BusinessRuleAction.prioritizeSale => 'Marca el producto como prioridad',
};

String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
