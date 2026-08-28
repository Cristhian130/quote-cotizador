enum BusinessRuleCondition {
  inventoryAge,
  highStockLowRotation,
  cityInventoryDifference,
}

enum BusinessRuleAction {
  applyDiscount,
  transferProduct,
  prioritizeSale,
}

class BusinessRule {
  final String id;
  final String name;
  final BusinessRuleCondition condition;
  final double threshold;
  final BusinessRuleAction action;
  final double actionValue;
  final bool enabled;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessRule({
    required this.id,
    required this.name,
    required this.condition,
    required this.threshold,
    required this.action,
    required this.actionValue,
    required this.enabled,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessRule.fromJson(Map<String, dynamic> json) {
    final created = _date(
      json['createdAt'] ?? json['fechaCreacion'] ?? json['created_at'],
    );
    return BusinessRule(
      id: '${json['id'] ?? json['reglaId'] ?? json['idRegla'] ?? ''}',
      name: '${json['nombre'] ?? json['name'] ?? ''}',
      condition: _condition(
        json['tipo'] ??
            json['tipoCondicion'] ??
            json['tipo_condicion'] ??
            json['conditionType'],
      ),
      threshold: _double(json['umbral'] ?? json['threshold']),
      action: _action(
        json['accion'] ??
            json['tipoAccion'] ??
            json['tipo_accion'] ??
            json['actionType'],
      ),
      actionValue: _double(
        json['valorAccion'] ?? json['valor_accion'] ?? json['actionValue'],
      ),
      enabled: _bool(json['activa'] ?? json['activo'] ?? json['enabled']),
      isDefault: _bool(
        json['preset'] ??
            json['esPredeterminada'] ??
            json['isDefault'] ??
            json['es_predeterminada'],
      ),
      createdAt: created,
      updatedAt: _date(
        json['updatedAt'] ??
            json['fechaActualizacion'] ??
            json['updated_at'] ??
            created,
      ),
    );
  }

  factory BusinessRule.fromDatabase(Map<String, Object?> row) {
    return BusinessRule(
      id: '${row['id'] ?? ''}',
      name: '${row['nombre'] ?? ''}',
      condition: _condition(row['tipo_condicion']),
      threshold: _double(row['umbral']),
      action: _action(row['tipo_accion']),
      actionValue: _double(row['valor_accion']),
      enabled: row['activa'] == 1,
      isDefault: row['es_predeterminada'] == 1,
      createdAt: _date(row['created_at']),
      updatedAt: _date(row['updated_at']),
    );
  }

  BusinessRule copyWith({
    String? name,
    BusinessRuleCondition? condition,
    double? threshold,
    BusinessRuleAction? action,
    double? actionValue,
    bool? enabled,
    bool? isDefault,
    DateTime? updatedAt,
  }) {
    return BusinessRule(
      id: id,
      name: name ?? this.name,
      condition: condition ?? this.condition,
      threshold: threshold ?? this.threshold,
      action: action ?? this.action,
      actionValue: actionValue ?? this.actionValue,
      enabled: enabled ?? this.enabled,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toDatabase() => {
    'id': id,
    'nombre': name,
    'tipo_condicion': condition.name,
    'umbral': threshold,
    'tipo_accion': action.name,
    'valor_accion': actionValue,
    'activa': enabled ? 1 : 0,
    'es_predeterminada': isDefault ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Map<String, Object?> toApiJson() => {
    'nombre': name,
    'tipo': condition.apiValue,
    'umbral': threshold,
    'accion': action.apiValue,
    'valorAccion': action == BusinessRuleAction.prioritizeSale
        ? 0
        : actionValue,
    'activa': enabled,
  };
}

extension BusinessRuleConditionApi on BusinessRuleCondition {
  String get apiValue => switch (this) {
    BusinessRuleCondition.inventoryAge => 'dias_inventario',
    BusinessRuleCondition.highStockLowRotation => 'stock_alto_baja_rotacion',
    BusinessRuleCondition.cityInventoryDifference => 'diferencia_ciudades',
  };
}

extension BusinessRuleActionApi on BusinessRuleAction {
  String get apiValue => switch (this) {
    BusinessRuleAction.applyDiscount => 'aplicar_descuento',
    BusinessRuleAction.transferProduct => 'trasladar_producto',
    BusinessRuleAction.prioritizeSale => 'priorizar_venta',
  };
}

BusinessRuleCondition _condition(Object? value) {
  return switch ('$value'.trim().toLowerCase()) {
    'highstocklowrotation' ||
    'stock_alto_rotacion_baja' ||
    'stock_alto_baja_rotacion' => BusinessRuleCondition.highStockLowRotation,
    'cityinventorydifference' ||
    'diferencia_ciudades' ||
    'diferencia_entre_ciudades' =>
      BusinessRuleCondition.cityInventoryDifference,
    _ => BusinessRuleCondition.inventoryAge,
  };
}

BusinessRuleAction _action(Object? value) {
  return switch ('$value'.trim().toLowerCase()) {
    'transferproduct' || 'trasladar_producto' =>
      BusinessRuleAction.transferProduct,
    'prioritizesale' || 'priorizar_venta' =>
      BusinessRuleAction.prioritizeSale,
    _ => BusinessRuleAction.applyDiscount,
  };
}

double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

DateTime _date(Object? value) =>
    DateTime.tryParse('${value ?? ''}') ?? DateTime.fromMillisecondsSinceEpoch(0);

bool _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return const {'true', '1', 'si', 'sí', 'yes'}
      .contains('$value'.trim().toLowerCase());
}
