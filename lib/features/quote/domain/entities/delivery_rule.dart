class DeliveryRule {
  final String cia;
  final String co;
  final int oi;
  final String moneda;
  final String tipoV;
  final String planCliente;
  final String criterioCli;
  final String bodegaId;
  final String paisOrigen;
  final String dptoOrigen;
  final String ciudadOrigen;
  final String barrioOrigen;
  final String paisDestino;
  final String dptoDestino;
  final String ciudadDestino;
  final String barrioDestino;
  final double tarifa;
  final int diasEntrega;
  final String fechaActualizacion;

  DeliveryRule({
    required this.cia,
    required this.co,
    required this.oi,
    required this.moneda,
    required this.tipoV,
    required this.planCliente,
    required this.criterioCli,
    required this.bodegaId,
    required this.paisOrigen,
    required this.dptoOrigen,
    required this.ciudadOrigen,
    required this.barrioOrigen,
    required this.paisDestino,
    required this.dptoDestino,
    required this.ciudadDestino,
    required this.barrioDestino,
    required this.tarifa,
    required this.diasEntrega,
    required this.fechaActualizacion,
  });

  factory DeliveryRule.fromJson(Map<String, dynamic> json) {
    return DeliveryRule(
      cia: json['cia']?.toString() ?? '',
      co: json['co']?.toString() ?? '',
      oi: (json['oi'] is int)
          ? json['oi']
          : int.tryParse(json['oi']?.toString() ?? '0') ?? 0,
      moneda: json['moneda']?.toString() ?? '',
      tipoV: json['tipoV']?.toString() ?? '',
      planCliente: json['planCliente']?.toString() ?? '',
      criterioCli: json['criterioCli']?.toString() ?? '',
      bodegaId: json['bodegaId']?.toString() ?? '',
      paisOrigen: json['paisOrigen']?.toString() ?? '',
      dptoOrigen: json['dptoOrigen']?.toString() ?? '',
      ciudadOrigen: json['ciudadOrigen']?.toString() ?? '',
      barrioOrigen: json['barrioOrigen']?.toString() ?? '',
      paisDestino: json['paisDestino']?.toString() ?? '',
      dptoDestino: json['dptoDestino']?.toString() ?? '',
      ciudadDestino: json['ciudadDestino']?.toString() ?? '',
      barrioDestino: json['barrioDestino']?.toString() ?? '',
      tarifa: (json['tarifa'] is num)
          ? json['tarifa'].toDouble()
          : double.tryParse(json['tarifa']?.toString() ?? '0') ?? 0.0,
      diasEntrega: (json['diasEntrega'] is int)
          ? json['diasEntrega']
          : int.tryParse(json['diasEntrega']?.toString() ?? '0') ?? 0,
      fechaActualizacion: json['fechaActualizacion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cia': cia,
      'co': co,
      'oi': oi,
      'moneda': moneda,
      'tipoV': tipoV,
      'planCliente': planCliente,
      'criterioCli': criterioCli,
      'bodegaId': bodegaId,
      'paisOrigen': paisOrigen,
      'dptoOrigen': dptoOrigen,
      'ciudadOrigen': ciudadOrigen,
      'barrioOrigen': barrioOrigen,
      'paisDestino': paisDestino,
      'dptoDestino': dptoDestino,
      'ciudadDestino': ciudadDestino,
      'barrioDestino': barrioDestino,
      'tarifa': tarifa,
      'diasEntrega': diasEntrega,
      'fechaActualizacion': fechaActualizacion,
    };
  }
}
