class InventoryFilters {
  final String query;
  final String companyId;
  final String warehouse;
  final String city;
  final String operationCenter;
  final bool searchByDescription;
  final bool onlyAvailable;
  final int limit;

  const InventoryFilters({
    this.query = '',
    this.companyId = '',
    this.warehouse = '',
    this.city = '',
    this.operationCenter = '',
    this.searchByDescription = false,
    this.onlyAvailable = true,
    this.limit = 200,
  });

  InventoryFilters copyWith({
    String? query,
    String? companyId,
    String? warehouse,
    String? city,
    String? operationCenter,
    bool? searchByDescription,
    bool? onlyAvailable,
    int? limit,
  }) {
    return InventoryFilters(
      query: query ?? this.query,
      companyId: companyId ?? this.companyId,
      warehouse: warehouse ?? this.warehouse,
      city: city ?? this.city,
      operationCenter: operationCenter ?? this.operationCenter,
      searchByDescription: searchByDescription ?? this.searchByDescription,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      limit: limit ?? this.limit,
    );
  }
}

class InventoryItem {
  final String reference;
  final String description;
  final String warehouse;
  final String companyId;
  final String operationCenter;
  final String city;
  final double stock;
  final double available;
  final String location;
  final double retailPrice;
  final double professionalPrice;
  final double tax;
  final String brandCode;
  final String brandDescription;
  final int brandPriority;
  final String subgroupCode;
  final bool allowsDiscount;
  final bool ambiguousWarehouse;
  final DateTime? updatedAt;

  const InventoryItem({
    required this.reference,
    required this.description,
    required this.warehouse,
    required this.companyId,
    required this.operationCenter,
    required this.city,
    required this.stock,
    required this.available,
    required this.location,
    required this.retailPrice,
    required this.professionalPrice,
    required this.tax,
    required this.brandCode,
    required this.brandDescription,
    required this.brandPriority,
    required this.subgroupCode,
    required this.allowsDiscount,
    required this.ambiguousWarehouse,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      reference: '${json['referencia'] ?? ''}',
      description: '${json['descripcion'] ?? ''}',
      warehouse: '${json['bodega'] ?? ''}',
      companyId: '${json['bodegaIdEmpresa'] ?? json['idEmpresa'] ?? ''}',
      operationCenter:
          '${json['bodegaCentroOperacion'] ?? json['centroOperacion'] ?? ''}',
      city: '${json['bodegaCiudadNormalizada'] ?? json['ciudadNormalizada'] ?? ''}',
      stock: _asDouble(json['existencia']),
      available: _asDouble(json['disponible']),
      location: '${json['ubicacion'] ?? ''}',
      retailPrice: _asDouble(json['precioParti']),
      professionalPrice: _asDouble(json['precioProfe']),
      tax: _asDouble(json['iva']),
      brandCode: '${json['proveedorMarcaCodigo'] ?? ''}',
      brandDescription: '${json['proveedorMarcaDescripcion'] ?? ''}',
      brandPriority: _asInt(json['prioridadMarca'], fallback: 99),
      subgroupCode: '${json['subgrupoCodigo'] ?? ''}',
      allowsDiscount: _asBool(json['aplicaDescuento'], fallback: true),
      ambiguousWarehouse: _asBool(json['bodegaAmbigua']),
      updatedAt: DateTime.tryParse('${json['fechaActualizacion'] ?? ''}'),
    );
  }

  factory InventoryItem.fromDatabase(Map<String, Object?> row) {
    return InventoryItem(
      reference: '${row['referencia'] ?? ''}',
      description: '${row['descripcion'] ?? ''}',
      warehouse: '${row['bodega'] ?? ''}',
      companyId: '${row['id_empresa'] ?? ''}',
      operationCenter: '${row['centro_operacion'] ?? ''}',
      city: '${row['ciudad_normalizada'] ?? ''}',
      stock: _asDouble(row['existencia']),
      available: _asDouble(row['disponible']),
      location: '${row['ubicacion'] ?? ''}',
      retailPrice: _asDouble(row['precio_parti']),
      professionalPrice: _asDouble(row['precio_profe']),
      tax: _asDouble(row['iva']),
      brandCode: '${row['proveedor_marca_codigo'] ?? ''}',
      brandDescription: '${row['proveedor_marca_descripcion'] ?? ''}',
      brandPriority: _asInt(row['prioridad_marca'], fallback: 99),
      subgroupCode: '${row['subgrupo_codigo'] ?? ''}',
      allowsDiscount: _asBool(row['aplica_descuento'], fallback: true),
      ambiguousWarehouse: _asBool(row['bodega_ambigua']),
      updatedAt: DateTime.tryParse('${row['fecha_actualizacion'] ?? ''}'),
    );
  }

  Map<String, Object?> toDatabase(DateTime syncedAt) {
    return {
      'local_key': '$reference|$warehouse|$companyId',
      'referencia': reference,
      'descripcion': description,
      'bodega': warehouse,
      'id_empresa': companyId,
      'centro_operacion': operationCenter,
      'ciudad_normalizada': city,
      'existencia': stock,
      'disponible': available,
      'ubicacion': location,
      'precio_parti': retailPrice,
      'precio_profe': professionalPrice,
      'iva': tax,
      'proveedor_marca_codigo': brandCode,
      'proveedor_marca_descripcion': brandDescription,
      'prioridad_marca': brandPriority,
      'subgrupo_codigo': subgroupCode,
      'aplica_descuento': allowsDiscount ? 1 : 0,
      'bodega_ambigua': ambiguousWarehouse ? 1 : 0,
      'fecha_actualizacion': updatedAt?.toIso8601String(),
      'synced_at': syncedAt.toIso8601String(),
    };
  }
}

double _asDouble(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _asInt(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

bool _asBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value == null) return fallback;
  return const {'true', '1', 'si', 'sí', 'yes', 'y'}
      .contains('$value'.trim().toLowerCase());
}
