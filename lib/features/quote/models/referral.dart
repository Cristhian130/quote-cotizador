class Referral {
  final String numeroDocumento;
  final String nombre;
  final String celular;
  final String estado;
  final String socioActual;
  final DateTime? ultimaFechaFin;

  Referral({
    required this.numeroDocumento,
    required this.nombre,
    required this.celular,
    required this.estado,
    required this.socioActual,
    this.ultimaFechaFin,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      numeroDocumento: json['numeroDocumento'] ?? '',
      nombre: json['nombre'] ?? '',
      celular: json['celular'] ?? '',
      estado: json['estado'] ?? '',
      socioActual: json['socioActual'] ?? '',
      ultimaFechaFin: json['ultimaFechaFin'] != null
          ? DateTime.tryParse(json['ultimaFechaFin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDocumento': numeroDocumento,
      'nombre': nombre,
      'celular': celular,
      'estado': estado,
      'socioActual': socioActual,
      'ultimaFechaFin': ultimaFechaFin?.toIso8601String(),
    };
  }
}
