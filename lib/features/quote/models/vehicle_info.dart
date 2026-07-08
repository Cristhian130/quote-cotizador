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
    // La nueva API anida la información dentro de 'vin de este vehiculo'
    final vinInfo = json['vin de este vehiculo'] as Map<String, dynamic>? ?? json;

    return VehicleInfo(
      marca: vinInfo['marca']?.toString() ?? '',
      linea: vinInfo['linea']?.toString() ?? '',
      version: vinInfo['version']?.toString() ?? '',
      modelo: vinInfo['modelo']?.toString() ?? '',
      vin: vinInfo['vin']?.toString() ?? '',
      vinEsReferenciaNoReal: vinInfo['vinEsReferenciaNoReal'] ?? false,
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
