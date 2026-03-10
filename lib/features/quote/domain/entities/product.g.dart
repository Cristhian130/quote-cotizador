// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  referencia: json['referencia'] as String,
  descripcion: json['descripcion'] as String,
  bodega: json['bodega'] as String,
  existencia: (json['existencia'] as num).toInt(),
  disponible: (json['disponible'] as num).toInt(),
  ubicacion: json['ubicacion'] as String?,
  precioParti: (json['precioParti'] as num).toDouble(),
  precioProfe: (json['precioProfe'] as num).toDouble(),
  iva: (json['iva'] as num).toDouble(),
  fechaActualizacion: DateTime.parse(json['fechaActualizacion'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'referencia': instance.referencia,
  'descripcion': instance.descripcion,
  'bodega': instance.bodega,
  'existencia': instance.existencia,
  'disponible': instance.disponible,
  'ubicacion': instance.ubicacion,
  'precioParti': instance.precioParti,
  'precioProfe': instance.precioProfe,
  'iva': instance.iva,
  'fechaActualizacion': instance.fechaActualizacion.toIso8601String(),
};
