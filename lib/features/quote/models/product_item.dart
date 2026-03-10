class ProductItem {
  final String id;
  final String referencia;
  final String descripcion;
  final String bodega;
  final int disponible;
  final String ubicacion;
  final double precioUnitario;
  final double iva;
  final double precioConIva;
  final double descuento;
  final double descuentoAplicado;
  final int cantidad;
  final double precioTotal;
  final double precioXUnidad;

  ProductItem({
    required this.id,
    required this.referencia,
    required this.descripcion,
    required this.bodega,
    required this.disponible,
    required this.ubicacion,
    required this.precioUnitario,
    required this.iva,
    required this.precioConIva,
    required this.descuento,
    required this.descuentoAplicado,
    required this.cantidad,
    required this.precioTotal,
    required this.precioXUnidad,
  });

  ProductItem copyWith({
    String? id,
    String? referencia,
    String? descripcion,
    String? bodega,
    int? disponible,
    String? ubicacion,
    double? precioUnitario,
    double? iva,
    double? precioConIva,
    double? descuento,
    double? descuentoAplicado,
    int? cantidad,
    double? precioTotal,
    double? precioXUnidad,
  }) {
    return ProductItem(
      id: id ?? this.id,
      referencia: referencia ?? this.referencia,
      descripcion: descripcion ?? this.descripcion,
      bodega: bodega ?? this.bodega,
      disponible: disponible ?? this.disponible,
      ubicacion: ubicacion ?? this.ubicacion,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      iva: iva ?? this.iva,
      precioConIva: precioConIva ?? this.precioConIva,
      descuento: descuento ?? this.descuento,
      descuentoAplicado: descuentoAplicado ?? this.descuentoAplicado,
      cantidad: cantidad ?? this.cantidad,
      precioTotal: precioTotal ?? this.precioTotal,
      precioXUnidad: precioXUnidad ?? this.precioXUnidad,
    );
  }
}
