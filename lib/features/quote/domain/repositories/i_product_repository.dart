import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class IProductRepository {
  /// Busca productos basandose en la estrategia de caché multinivel (Hive -> SQLite -> API).
  /// Si los datos locales superan las 4 horas de antigüedad, puede detonar sync en background.
  Future<Either<Failure, List<Product>>> searchProducts({
    String? referencia,
    String? descripcion,
    String? bodega,
  });

  /// Obliga una sincronización desde la API remota hacia SQLite y limpia Hive.
  Future<Either<Failure, void>> syncProducts();
}
