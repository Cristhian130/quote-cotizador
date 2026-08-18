class AlertRules {
  final int minimumInventoryDays;
  final double minimumHighStock;
  final double maximumSales180Days;
  final List<String> lowRotationClassifications;
  final List<String> suggestions;
  final List<String> noDiscountSubgroups;
  final int defaultPageSize;
  final int maximumPageSize;
  final String recommendedPagination;

  const AlertRules({
    required this.minimumInventoryDays,
    required this.minimumHighStock,
    required this.maximumSales180Days,
    required this.lowRotationClassifications,
    required this.suggestions,
    required this.noDiscountSubgroups,
    required this.defaultPageSize,
    required this.maximumPageSize,
    required this.recommendedPagination,
  });

  factory AlertRules.fromJson(Map<String, dynamic> json) {
    final pagination =
        json['paginacion'] as Map<String, dynamic>? ?? const {};
    return AlertRules(
      minimumInventoryDays: _int(json['inventarioDiasMin']),
      minimumHighStock: _double(json['stockAltoMin']),
      maximumSales180Days: _double(json['ventasUltimos180Max']),
      lowRotationClassifications: _strings(
        json['bajaRotacionClasificaciones'],
      ),
      suggestions: _strings(json['sugerencias']),
      noDiscountSubgroups: _strings(json['subgruposSinDescuento']),
      defaultPageSize: _int(pagination['defaultPageSize'], fallback: 100),
      maximumPageSize: _int(pagination['maxPageSize'], fallback: 1000),
      recommendedPagination: '${pagination['recommendedMode'] ?? 'cursor'}',
    );
  }

  factory AlertRules.fromDatabase(Map<String, Object?> row) {
    return AlertRules(
      minimumInventoryDays: _int(row['inventario_dias_min']),
      minimumHighStock: _double(row['stock_alto_min']),
      maximumSales180Days: _double(row['ventas_ultimos_180_max']),
      lowRotationClassifications: _split(row['clasificaciones']),
      suggestions: _split(row['sugerencias']),
      noDiscountSubgroups: _split(row['subgrupos_sin_descuento']),
      defaultPageSize: _int(row['default_page_size'], fallback: 100),
      maximumPageSize: _int(row['max_page_size'], fallback: 1000),
      recommendedPagination: '${row['recommended_mode'] ?? 'cursor'}',
    );
  }

  Map<String, Object?> toDatabase(DateTime syncedAt) => {
    'id': 1,
    'inventario_dias_min': minimumInventoryDays,
    'stock_alto_min': minimumHighStock,
    'ventas_ultimos_180_max': maximumSales180Days,
    'clasificaciones': lowRotationClassifications.join('|'),
    'sugerencias': suggestions.join('|'),
    'subgrupos_sin_descuento': noDiscountSubgroups.join('|'),
    'default_page_size': defaultPageSize,
    'max_page_size': maximumPageSize,
    'recommended_mode': recommendedPagination,
    'synced_at': syncedAt.toIso8601String(),
  };
}

class RuleEvaluationFilters {
  final String companyId;
  final String city;
  final int pageSize;
  final double minimumStock;
  final int minimumDaysWithoutSale;

  const RuleEvaluationFilters({
    this.companyId = '',
    this.city = '',
    this.pageSize = 100,
    required this.minimumStock,
    required this.minimumDaysWithoutSale,
  });
}

List<String> _strings(Object? value) =>
    value is List ? value.map((item) => '$item').toList(growable: false) : [];

List<String> _split(Object? value) => '$value'
    .split('|')
    .where((item) => item.trim().isNotEmpty)
    .toList(growable: false);

double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _int(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
