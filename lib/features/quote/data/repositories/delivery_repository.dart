import '../datasources/sqlite_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../domain/entities/delivery_rule.dart';

class DeliveryRepository {
  final SqliteDataSource sqliteDataSource;
  final RemoteDataSource remoteDataSource;

  DeliveryRepository(this.sqliteDataSource, this.remoteDataSource);

  Future<void> syncDeliveryRules() async {
    try {
      final rules = await remoteDataSource.fetchDeliveryRules();
      await sqliteDataSource.bulkInsertDeliveryRules(rules);
    } catch (e) {
      print("Error syncing delivery rules: $e");
    }
  }

  Future<List<String>> getCitiesForBodega(String bodegaId) async {
    return await sqliteDataSource.getUniqueCitiesForBodega(bodegaId);
  }

  Future<List<String>> getBarrios(String bodegaId, String ciudad) async {
    return await sqliteDataSource.getUniqueBarrios(bodegaId, ciudad);
  }

  Future<DeliveryRule?> getTarifa({
    required String bodegaId,
    required String ciudadDestino,
    required String barrioDestino,
    required String tipoVehiculo,
  }) async {
    return await sqliteDataSource.getDeliveryRule(
      bodegaId: bodegaId,
      ciudadDestino: ciudadDestino,
      barrioDestino: barrioDestino,
      tipoV: tipoVehiculo,
    );
  }

  Future<List<String>> getVehiculos(
    String bodegaId,
    String ciudad,
    String barrio,
  ) async {
    return await sqliteDataSource.getUniqueVehiculos(bodegaId, ciudad, barrio);
  }
}
