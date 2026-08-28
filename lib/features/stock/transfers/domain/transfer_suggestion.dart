class TransferRequest {
  final String reference;
  final String companyId;
  final String originWarehouse;
  final String originOperationCenter;
  final int quantity;
  final int limit;

  const TransferRequest({
    required this.reference,
    required this.companyId,
    this.originWarehouse = '',
    this.originOperationCenter = '',
    this.quantity = 1,
    this.limit = 50,
  });

  Map<String, dynamic> toQueryParameters() => {
    'referencia': reference,
    'idEmpresa': companyId,
    if (originWarehouse.isNotEmpty) 'bodegaOrigen': originWarehouse,
    if (originOperationCenter.isNotEmpty)
      'centroOperacionOrigen': originOperationCenter,
    'cantidad': quantity,
    'limit': limit,
  };

  Map<String, dynamic> toPreviewJson() => toQueryParameters();
}

class CityTransferRequest {
  final String city;
  final String reference;
  final String companyId;
  final String originWarehouse;
  final String originOperationCenter;
  final int? quantity;
  final int? limit;

  const CityTransferRequest({
    required this.city,
    this.reference = '',
    this.companyId = '',
    this.originWarehouse = '',
    this.originOperationCenter = '',
    this.quantity,
    this.limit,
  });

  Map<String, dynamic> toQueryParameters() => {
    'ciudad': city,
    if (reference.isNotEmpty) 'referencia': reference,
    if (companyId.isNotEmpty) 'idEmpresa': companyId,
    if (originWarehouse.isNotEmpty) 'bodegaOrigen': originWarehouse,
    if (originOperationCenter.isNotEmpty)
      'centroOperacionOrigen': originOperationCenter,
    if (quantity != null) 'cantidad': quantity,
    if (limit != null) 'limit': limit,
  };
}

class TransferOrigin {
  final String warehouse;
  final String operationCenter;
  final String city;
  final String companyId;
  final String description;

  const TransferOrigin({
    required this.warehouse,
    required this.operationCenter,
    required this.city,
    required this.companyId,
    required this.description,
  });

  factory TransferOrigin.fromJson(Map<String, dynamic> json) => TransferOrigin(
    warehouse: '${json['bodega'] ?? ''}',
    operationCenter: '${json['centroOperacion'] ?? ''}',
    city: '${json['ciudadNormalizada'] ?? json['ciudad'] ?? ''}',
    companyId: '${json['idEmpresa'] ?? ''}',
    description: '${json['descripcionBodega'] ?? ''}',
  );
}

class TransferCandidate {
  final String reference;
  final String description;
  final String warehouse;
  final double available;
  final String city;
  final int cityPriority;
  final int brandPriority;
  final int transferOrder;
  final double requestedQuantity;
  final bool coversQuantity;

  const TransferCandidate({
    required this.reference,
    required this.description,
    required this.warehouse,
    required this.available,
    required this.city,
    required this.cityPriority,
    required this.brandPriority,
    required this.transferOrder,
    required this.requestedQuantity,
    required this.coversQuantity,
  });

  factory TransferCandidate.fromJson(Map<String, dynamic> json) =>
      TransferCandidate(
        reference: '${json['referencia'] ?? ''}',
        description: '${json['descripcion'] ?? ''}',
        warehouse: '${json['bodegaDestino'] ?? json['bodega'] ?? ''}',
        available: _double(
          json['stockDisponible'] ?? json['stockDestino'] ?? json['disponible'],
        ),
        city:
            '${json['ciudadNormalizada'] ?? json['bodegaCiudadNormalizada'] ?? json['ciudadDestino'] ?? ''}',
        cityPriority: _int(json['prioridadCiudad'], fallback: 99),
        brandPriority: _int(json['prioridadMarca'], fallback: 99),
        transferOrder: _int(json['ordenTraslado']),
        requestedQuantity: _double(json['cantidadSolicitada'] ?? json['cantidad']),
        coversQuantity: _bool(json['cubreCantidad']),
      );
}

class TransferCityInventory {
  final String warehouse;
  final String city;
  final double available;

  const TransferCityInventory({
    required this.warehouse,
    required this.city,
    required this.available,
  });

  factory TransferCityInventory.fromJson(Map<String, dynamic> json) =>
      TransferCityInventory(
        warehouse: '${json['bodega'] ?? ''}',
        city: '${json['ciudadNormalizada'] ?? json['ciudad'] ?? ''}',
        available: _double(json['stockDisponible'] ?? json['disponible']),
      );
}

class TransferSuggestionsResult {
  final TransferOrigin origin;
  final List<TransferCandidate> candidates;
  final int count;
  final String reference;
  final String description;
  final String quoteCity;
  final double quoteCityStock;
  final bool needsTransfer;
  final TransferCandidate? bestCandidate;
  final List<TransferCityInventory> quoteCityInventory;
  final String summary;

  const TransferSuggestionsResult({
    required this.origin,
    required this.candidates,
    required this.count,
    this.reference = '',
    this.description = '',
    this.quoteCity = '',
    this.quoteCityStock = 0,
    this.needsTransfer = false,
    this.bestCandidate,
    this.quoteCityInventory = const [],
    this.summary = '',
  });

  factory TransferSuggestionsResult.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? fallbackOrigin,
  }) {
    final wrapped = json['data'];
    final firstRow = wrapped is List && wrapped.isNotEmpty ? wrapped.first : null;
    final payload = wrapped is Map<String, dynamic>
        ? wrapped
        : firstRow is Map<String, dynamic> &&
              (firstRow.containsKey('candidatosTraslado') ||
                  firstRow.containsKey('mejorCandidato') ||
                  firstRow.containsKey('stockCiudadCotizacion'))
            ? firstRow
            : json;
    final origin = payload['origin'];
    final rawCandidates = payload['candidatosTraslado'] ?? payload['data'];
    final rawInventory = payload['inventarioCiudadCotizacion'];
    final rawBest = payload['mejorCandidato'];
    final candidates = rawCandidates is List
        ? rawCandidates
            .whereType<Map<String, dynamic>>()
            .map(TransferCandidate.fromJson)
            .toList(growable: false)
        : const <TransferCandidate>[];
    return TransferSuggestionsResult(
      origin: TransferOrigin.fromJson(
        origin is Map<String, dynamic>
            ? origin
            : (fallbackOrigin ?? const <String, dynamic>{}),
      ),
      candidates: candidates,
      count: _int(payload['count'], fallback: candidates.length),
      reference: '${payload['referencia'] ?? ''}',
      description: '${payload['descripcion'] ?? ''}',
      quoteCity: '${payload['ciudadCotizacion'] ?? ''}',
      quoteCityStock: _double(payload['stockCiudadCotizacion']),
      needsTransfer: _bool(payload['necesitaTraslado']),
      bestCandidate: rawBest is Map<String, dynamic> && rawBest.isNotEmpty
          ? TransferCandidate.fromJson(rawBest)
          : (candidates.isEmpty ? null : candidates.first),
      quoteCityInventory: rawInventory is List
          ? rawInventory
              .whereType<Map<String, dynamic>>()
              .map(TransferCityInventory.fromJson)
              .toList(growable: false)
          : const <TransferCityInventory>[],
      summary: '${payload['resumen'] ?? ''}',
    );
  }
}

class TransferPreview {
  final String status;
  final TransferOrigin? origin;
  final TransferCandidate? selected;
  final String reference;
  final int quantity;
  final int candidatesCount;

  const TransferPreview({
    required this.status,
    required this.origin,
    required this.selected,
    required this.reference,
    required this.quantity,
    required this.candidatesCount,
  });

  factory TransferPreview.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    final origin = json['origin'];
    final selected = json['selected'];
    return TransferPreview(
      status: '${json['status'] ?? ''}',
      origin: origin is Map<String, dynamic>
          ? TransferOrigin.fromJson(origin)
          : null,
      selected: selected is Map<String, dynamic> && selected.isNotEmpty
          ? TransferCandidate.fromJson(selected)
          : null,
      reference: metadata is Map<String, dynamic>
          ? '${metadata['referencia'] ?? ''}'
          : '',
      quantity: metadata is Map<String, dynamic>
          ? _int(metadata['cantidad'])
          : 0,
      candidatesCount: metadata is Map<String, dynamic>
          ? _int(metadata['candidatesCount'])
          : 0,
    );
  }
}

double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _int(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

bool _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return const {'true', '1', 'si', 'sí', 'yes', 'y'}
      .contains('$value'.trim().toLowerCase());
}
