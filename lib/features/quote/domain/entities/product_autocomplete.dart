class ProductAutocompleteSuggestion {
  final String reference;
  final String description;
  final String matchType;
  final int relevanceScore;
  final double nationalAvailableStock;
  final double nationalExistingStock;
  final int warehousesWithAvailability;
  final DateTime? updatedAt;

  const ProductAutocompleteSuggestion({
    required this.reference,
    required this.description,
    required this.matchType,
    required this.relevanceScore,
    required this.nationalAvailableStock,
    required this.nationalExistingStock,
    required this.warehousesWithAvailability,
    required this.updatedAt,
  });

  factory ProductAutocompleteSuggestion.fromJson(Map<String, dynamic> json) =>
      ProductAutocompleteSuggestion(
        reference: '${json['referencia'] ?? ''}',
        description: '${json['descripcion'] ?? ''}',
        matchType: '${json['tipoCoincidencia'] ?? ''}',
        relevanceScore: _int(json['puntajeRelevancia']),
        nationalAvailableStock: _double(json['stockDisponibleNacional']),
        nationalExistingStock: _double(json['stockExistenteNacional']),
        warehousesWithAvailability: _int(json['bodegasConDisponible']),
        updatedAt: DateTime.tryParse('${json['fechaActualizacion'] ?? ''}'),
      );
}

class ProductAutocompleteResult {
  final List<ProductAutocompleteSuggestion> suggestions;
  final bool isLocal;

  const ProductAutocompleteResult({
    required this.suggestions,
    this.isLocal = false,
  });
}

double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
