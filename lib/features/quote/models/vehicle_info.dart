class VehicleInfo {
  final String marca;
  final String linea;
  final String version;
  final String modelo;
  final String vin;
  final bool vinEsReferenciaNoReal;

  VehicleInfo({
    required this.marca,
    required this.linea,
    required this.version,
    required this.modelo,
    required this.vin,
    required this.vinEsReferenciaNoReal,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      marca: json['marca'] ?? '',
      linea: json['linea'] ?? '',
      version: json['version'] ?? '',
      modelo: json['modelo'] ?? '',
      vin: json['vin'] ?? '',
      vinEsReferenciaNoReal: json['vinEsReferenciaNoReal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marca': marca,
      'linea': linea,
      'version': version,
      'modelo': modelo,
      'vin': vin,
      'vinEsReferenciaNoReal': vinEsReferenciaNoReal,
    };
  }
}
