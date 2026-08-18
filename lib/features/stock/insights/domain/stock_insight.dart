class InsightFilters {
  final String query;
  final String companyId;
  final String warehouse;
  final String city;
  final String classification;
  final String frequency;
  final String suggestion;
  final bool searchByDescription;
  final double? minimumStock;
  final int? minimumDaysWithoutSale;
  final bool onlyAlerts;
  final int pageSize;
  final int? cursor;

  const InsightFilters({
    this.query = '',
    this.companyId = '',
    this.warehouse = '',
    this.city = '',
    this.classification = '',
    this.frequency = '',
    this.suggestion = '',
    this.searchByDescription = false,
    this.minimumStock,
    this.minimumDaysWithoutSale,
    this.onlyAlerts = false,
    this.pageSize = 100,
    this.cursor,
  });

  InsightFilters copyWith({
    String? query,
    String? companyId,
    String? warehouse,
    String? city,
    String? classification,
    String? frequency,
    String? suggestion,
    bool? searchByDescription,
    double? minimumStock,
    int? minimumDaysWithoutSale,
    bool? onlyAlerts,
    int? pageSize,
    int? cursor,
    bool clearCursor = false,
  }) {
    return InsightFilters(
      query: query ?? this.query,
      companyId: companyId ?? this.companyId,
      warehouse: warehouse ?? this.warehouse,
      city: city ?? this.city,
      classification: classification ?? this.classification,
      frequency: frequency ?? this.frequency,
      suggestion: suggestion ?? this.suggestion,
      searchByDescription: searchByDescription ?? this.searchByDescription,
      minimumStock: minimumStock ?? this.minimumStock,
      minimumDaysWithoutSale:
          minimumDaysWithoutSale ?? this.minimumDaysWithoutSale,
      onlyAlerts: onlyAlerts ?? this.onlyAlerts,
      pageSize: pageSize ?? this.pageSize,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
    );
  }
}

class InsightPage {
  final List<StockInsight> items;
  final String runId;
  final int? nextCursor;
  final int? total;

  const InsightPage({
    required this.items,
    required this.runId,
    this.nextCursor,
    this.total,
  });
}

class StockInsight {
  final int snapshotId;
  final String runId;
  final DateTime? snapshotDate;
  final String companyId;
  final String warehouse;
  final String operationCenter;
  final String city;
  final String reference;
  final String description;
  final int brandPriority;
  final String classification;
  final String frequency;
  final int daysWithoutSale;
  final double availableStock;
  final double existingStock;
  final double sales90Days;
  final double sales180Days;
  final double rotation;
  final bool highStockLowRotation;
  final bool allowsDiscount;
  final String commercialSuggestion;

  const StockInsight({
    required this.snapshotId,
    required this.runId,
    required this.snapshotDate,
    required this.companyId,
    required this.warehouse,
    required this.operationCenter,
    required this.city,
    required this.reference,
    required this.description,
    required this.brandPriority,
    required this.classification,
    required this.frequency,
    required this.daysWithoutSale,
    required this.availableStock,
    required this.existingStock,
    required this.sales90Days,
    required this.sales180Days,
    required this.rotation,
    required this.highStockLowRotation,
    required this.allowsDiscount,
    required this.commercialSuggestion,
  });

  factory StockInsight.fromJson(Map<String, dynamic> json) {
    return StockInsight(
      snapshotId: _int(json['snapshotId']),
      runId: '${json['runId'] ?? ''}',
      snapshotDate: DateTime.tryParse('${json['fechaSnapshot'] ?? ''}'),
      companyId: '${json['idEmpresa'] ?? ''}',
      warehouse: '${json['bodega'] ?? ''}',
      operationCenter: '${json['centroOperacion'] ?? ''}',
      city: '${json['ciudadNormalizada'] ?? ''}',
      reference: '${json['referencia'] ?? ''}',
      description: '${json['descripcion'] ?? ''}',
      brandPriority: _int(json['prioridadMarca'], fallback: 99),
      classification: '${json['clasificacionABC'] ?? ''}',
      frequency: '${json['frecuencia'] ?? ''}',
      daysWithoutSale: _int(json['diasSinVenta']),
      availableStock: _double(json['stockDisponible']),
      existingStock: _double(json['stockExistente']),
      sales90Days: _double(json['ventasUltimos90Dias']),
      sales180Days: _double(json['ventasUltimos180Dias']),
      rotation: _double(json['rotacion']),
      highStockLowRotation: _bool(json['stockAltoBajaRotacion']),
      allowsDiscount: _bool(json['aplicaDescuento'], fallback: true),
      commercialSuggestion: '${json['sugerenciaComercial'] ?? ''}',
    );
  }

  factory StockInsight.fromDatabase(Map<String, Object?> row) {
    return StockInsight(
      snapshotId: _int(row['snapshot_id']),
      runId: '${row['run_id'] ?? ''}',
      snapshotDate: DateTime.tryParse('${row['fecha_snapshot'] ?? ''}'),
      companyId: '${row['id_empresa'] ?? ''}',
      warehouse: '${row['bodega'] ?? ''}',
      operationCenter: '${row['centro_operacion'] ?? ''}',
      city: '${row['ciudad_normalizada'] ?? ''}',
      reference: '${row['referencia'] ?? ''}',
      description: '${row['descripcion'] ?? ''}',
      brandPriority: _int(row['prioridad_marca'], fallback: 99),
      classification: '${row['clasificacion_abc'] ?? ''}',
      frequency: '${row['frecuencia'] ?? ''}',
      daysWithoutSale: _int(row['dias_sin_venta']),
      availableStock: _double(row['stock_disponible']),
      existingStock: _double(row['stock_existente']),
      sales90Days: _double(row['ventas_ultimos_90_dias']),
      sales180Days: _double(row['ventas_ultimos_180_dias']),
      rotation: _double(row['rotacion']),
      highStockLowRotation: _bool(row['stock_alto_baja_rotacion']),
      allowsDiscount: _bool(row['aplica_descuento'], fallback: true),
      commercialSuggestion: '${row['sugerencia_comercial'] ?? ''}',
    );
  }

  Map<String, Object?> toDatabase(DateTime syncedAt) => {
    'snapshot_id': snapshotId,
    'run_id': runId,
    'fecha_snapshot': snapshotDate?.toIso8601String(),
    'id_empresa': companyId,
    'bodega': warehouse,
    'centro_operacion': operationCenter,
    'ciudad_normalizada': city,
    'referencia': reference,
    'descripcion': description,
    'prioridad_marca': brandPriority,
    'clasificacion_abc': classification,
    'frecuencia': frequency,
    'dias_sin_venta': daysWithoutSale,
    'stock_disponible': availableStock,
    'stock_existente': existingStock,
    'ventas_ultimos_90_dias': sales90Days,
    'ventas_ultimos_180_dias': sales180Days,
    'rotacion': rotation,
    'stock_alto_baja_rotacion': highStockLowRotation ? 1 : 0,
    'aplica_descuento': allowsDiscount ? 1 : 0,
    'sugerencia_comercial': commercialSuggestion,
    'synced_at': syncedAt.toIso8601String(),
  };
}

double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _int(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

bool _bool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value == null) return fallback;
  return const {'true', '1', 'si', 'sí', 'yes', 'y'}
      .contains('$value'.trim().toLowerCase());
}
