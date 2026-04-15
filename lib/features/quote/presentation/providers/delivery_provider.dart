import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sqlite_data_source.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../domain/entities/delivery_rule.dart';

import 'product_provider.dart';

final sqliteDataSourceProvider = Provider<SqliteDataSource>((ref) {
  return SqliteDataSource();
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final sqlite = ref.watch(sqliteDataSourceProvider);
  final remote = ref.watch(remoteDataSourceProvider);
  return DeliveryRepository(sqlite, remote);
});

// Auto-sync delivery rules on app load
final syncDeliveryRulesProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  await repo.syncDeliveryRules();

  // Refrescar los selectores en la UI después de guardar en SQLite
  ref.invalidate(deliveryCitiesProvider);
  ref.invalidate(deliveryBarriosProvider);
  ref.invalidate(deliveryVehiculosProvider);
  ref.invalidate(deliveryTarifaProvider);
});

// Proveedor para obtener ciudades de una bodega específica
final deliveryCitiesProvider = FutureProvider.family<List<String>, String>((
  ref,
  bodegaId,
) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getCitiesForBodega(bodegaId);
});

// Proveedor para obtener barrios según bodega y ciudad
final deliveryBarriosProvider =
    FutureProvider.family<List<String>, ({String bodegaId, String ciudad})>((
      ref,
      args,
    ) async {
      if (args.ciudad.isEmpty) return [];
      final repo = ref.watch(deliveryRepositoryProvider);
      return repo.getBarrios(args.bodegaId, args.ciudad);
    });

// Proveedor para obtener vehiculos según bodega, ciudad y barrio
final deliveryVehiculosProvider =
    FutureProvider.family<
      List<String>,
      ({String bodegaId, String ciudad, String barrio})
    >((ref, args) async {
      if (args.ciudad.isEmpty || args.barrio.isEmpty) return [];
      final repo = ref.watch(deliveryRepositoryProvider);
      return repo.getVehiculos(args.bodegaId, args.ciudad, args.barrio);
    });

// Proveedor para obtener la tarifa final calculada
final deliveryTarifaProvider =
    FutureProvider.family<
      DeliveryRule?,
      ({String bodegaId, String ciudad, String barrio, String tipoVehiculo})
    >((ref, args) async {
      if (args.ciudad.isEmpty ||
          args.barrio.isEmpty ||
          args.tipoVehiculo.isEmpty) {
        return null;
      }
      final repo = ref.watch(deliveryRepositoryProvider);
      return repo.getTarifa(
        bodegaId: args.bodegaId,
        ciudadDestino: args.ciudad,
        barrioDestino: args.barrio,
        tipoVehiculo: args.tipoVehiculo,
      );
    });
