import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/hive_database.dart';
import '../../business_rules/data/rules_local_data_source.dart';
import '../../business_rules/data/rules_remote_data_source.dart';
import '../../business_rules/data/rules_repository_impl.dart';
import '../../business_rules/domain/rules_repository.dart';
import '../../insights/data/insights_local_data_source.dart';
import '../../insights/data/insights_remote_data_source.dart';
import '../../insights/data/insights_repository_impl.dart';
import '../../insights/domain/insights_repository.dart';
import '../../inventory/data/inventory_local_data_source.dart';
import '../../inventory/data/inventory_remote_data_source.dart';
import '../../inventory/data/inventory_repository_impl.dart';
import '../../inventory/domain/inventory_repository.dart';

final stockDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 8),
      headers: const {'ngrok-skip-browser-warning': 'true'},
    ),
  );
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    remote: InventoryRemoteDataSource(ref.watch(stockDioProvider)),
    local: InventoryLocalDataSource(),
    syncBox: HiveDatabase.syncBox,
  );
});

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  return InsightsRepositoryImpl(
    remote: InsightsRemoteDataSource(ref.watch(stockDioProvider)),
    local: InsightsLocalDataSource(),
    syncBox: HiveDatabase.syncBox,
  );
});

final rulesRepositoryProvider = Provider<RulesRepository>((ref) {
  return RulesRepositoryImpl(
    remote: RulesRemoteDataSource(ref.watch(stockDioProvider)),
    local: RulesLocalDataSource(),
    syncBox: HiveDatabase.syncBox,
  );
});
