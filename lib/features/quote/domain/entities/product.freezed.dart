// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get referencia; String get descripcion; String get bodega; int get existencia; int get disponible; String? get ubicacion; double get precioParti; double get precioProfe; double get iva; DateTime get fechaActualizacion;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.referencia, referencia) || other.referencia == referencia)&&(identical(other.descripcion, descripcion) || other.descripcion == descripcion)&&(identical(other.bodega, bodega) || other.bodega == bodega)&&(identical(other.existencia, existencia) || other.existencia == existencia)&&(identical(other.disponible, disponible) || other.disponible == disponible)&&(identical(other.ubicacion, ubicacion) || other.ubicacion == ubicacion)&&(identical(other.precioParti, precioParti) || other.precioParti == precioParti)&&(identical(other.precioProfe, precioProfe) || other.precioProfe == precioProfe)&&(identical(other.iva, iva) || other.iva == iva)&&(identical(other.fechaActualizacion, fechaActualizacion) || other.fechaActualizacion == fechaActualizacion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,referencia,descripcion,bodega,existencia,disponible,ubicacion,precioParti,precioProfe,iva,fechaActualizacion);

@override
String toString() {
  return 'Product(referencia: $referencia, descripcion: $descripcion, bodega: $bodega, existencia: $existencia, disponible: $disponible, ubicacion: $ubicacion, precioParti: $precioParti, precioProfe: $precioProfe, iva: $iva, fechaActualizacion: $fechaActualizacion)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String referencia, String descripcion, String bodega, int existencia, int disponible, String? ubicacion, double precioParti, double precioProfe, double iva, DateTime fechaActualizacion
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? referencia = null,Object? descripcion = null,Object? bodega = null,Object? existencia = null,Object? disponible = null,Object? ubicacion = freezed,Object? precioParti = null,Object? precioProfe = null,Object? iva = null,Object? fechaActualizacion = null,}) {
  return _then(_self.copyWith(
referencia: null == referencia ? _self.referencia : referencia // ignore: cast_nullable_to_non_nullable
as String,descripcion: null == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String,bodega: null == bodega ? _self.bodega : bodega // ignore: cast_nullable_to_non_nullable
as String,existencia: null == existencia ? _self.existencia : existencia // ignore: cast_nullable_to_non_nullable
as int,disponible: null == disponible ? _self.disponible : disponible // ignore: cast_nullable_to_non_nullable
as int,ubicacion: freezed == ubicacion ? _self.ubicacion : ubicacion // ignore: cast_nullable_to_non_nullable
as String?,precioParti: null == precioParti ? _self.precioParti : precioParti // ignore: cast_nullable_to_non_nullable
as double,precioProfe: null == precioProfe ? _self.precioProfe : precioProfe // ignore: cast_nullable_to_non_nullable
as double,iva: null == iva ? _self.iva : iva // ignore: cast_nullable_to_non_nullable
as double,fechaActualizacion: null == fechaActualizacion ? _self.fechaActualizacion : fechaActualizacion // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String referencia,  String descripcion,  String bodega,  int existencia,  int disponible,  String? ubicacion,  double precioParti,  double precioProfe,  double iva,  DateTime fechaActualizacion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.referencia,_that.descripcion,_that.bodega,_that.existencia,_that.disponible,_that.ubicacion,_that.precioParti,_that.precioProfe,_that.iva,_that.fechaActualizacion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String referencia,  String descripcion,  String bodega,  int existencia,  int disponible,  String? ubicacion,  double precioParti,  double precioProfe,  double iva,  DateTime fechaActualizacion)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.referencia,_that.descripcion,_that.bodega,_that.existencia,_that.disponible,_that.ubicacion,_that.precioParti,_that.precioProfe,_that.iva,_that.fechaActualizacion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String referencia,  String descripcion,  String bodega,  int existencia,  int disponible,  String? ubicacion,  double precioParti,  double precioProfe,  double iva,  DateTime fechaActualizacion)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.referencia,_that.descripcion,_that.bodega,_that.existencia,_that.disponible,_that.ubicacion,_that.precioParti,_that.precioProfe,_that.iva,_that.fechaActualizacion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product extends Product {
  const _Product({required this.referencia, required this.descripcion, required this.bodega, required this.existencia, required this.disponible, required this.ubicacion, required this.precioParti, required this.precioProfe, required this.iva, required this.fechaActualizacion}): super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String referencia;
@override final  String descripcion;
@override final  String bodega;
@override final  int existencia;
@override final  int disponible;
@override final  String? ubicacion;
@override final  double precioParti;
@override final  double precioProfe;
@override final  double iva;
@override final  DateTime fechaActualizacion;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.referencia, referencia) || other.referencia == referencia)&&(identical(other.descripcion, descripcion) || other.descripcion == descripcion)&&(identical(other.bodega, bodega) || other.bodega == bodega)&&(identical(other.existencia, existencia) || other.existencia == existencia)&&(identical(other.disponible, disponible) || other.disponible == disponible)&&(identical(other.ubicacion, ubicacion) || other.ubicacion == ubicacion)&&(identical(other.precioParti, precioParti) || other.precioParti == precioParti)&&(identical(other.precioProfe, precioProfe) || other.precioProfe == precioProfe)&&(identical(other.iva, iva) || other.iva == iva)&&(identical(other.fechaActualizacion, fechaActualizacion) || other.fechaActualizacion == fechaActualizacion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,referencia,descripcion,bodega,existencia,disponible,ubicacion,precioParti,precioProfe,iva,fechaActualizacion);

@override
String toString() {
  return 'Product(referencia: $referencia, descripcion: $descripcion, bodega: $bodega, existencia: $existencia, disponible: $disponible, ubicacion: $ubicacion, precioParti: $precioParti, precioProfe: $precioProfe, iva: $iva, fechaActualizacion: $fechaActualizacion)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String referencia, String descripcion, String bodega, int existencia, int disponible, String? ubicacion, double precioParti, double precioProfe, double iva, DateTime fechaActualizacion
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? referencia = null,Object? descripcion = null,Object? bodega = null,Object? existencia = null,Object? disponible = null,Object? ubicacion = freezed,Object? precioParti = null,Object? precioProfe = null,Object? iva = null,Object? fechaActualizacion = null,}) {
  return _then(_Product(
referencia: null == referencia ? _self.referencia : referencia // ignore: cast_nullable_to_non_nullable
as String,descripcion: null == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String,bodega: null == bodega ? _self.bodega : bodega // ignore: cast_nullable_to_non_nullable
as String,existencia: null == existencia ? _self.existencia : existencia // ignore: cast_nullable_to_non_nullable
as int,disponible: null == disponible ? _self.disponible : disponible // ignore: cast_nullable_to_non_nullable
as int,ubicacion: freezed == ubicacion ? _self.ubicacion : ubicacion // ignore: cast_nullable_to_non_nullable
as String?,precioParti: null == precioParti ? _self.precioParti : precioParti // ignore: cast_nullable_to_non_nullable
as double,precioProfe: null == precioProfe ? _self.precioProfe : precioProfe // ignore: cast_nullable_to_non_nullable
as double,iva: null == iva ? _self.iva : iva // ignore: cast_nullable_to_non_nullable
as double,fechaActualizacion: null == fechaActualizacion ? _self.fechaActualizacion : fechaActualizacion // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
