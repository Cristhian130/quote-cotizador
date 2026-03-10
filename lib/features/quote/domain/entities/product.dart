import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required String referencia,
    required String descripcion,
    required String bodega,
    required int existencia,
    required int disponible,
    required String? ubicacion,
    required double precioParti,
    required double precioProfe,
    required double iva,
    required DateTime fechaActualizacion,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
