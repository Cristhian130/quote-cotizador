import 'package:hive/hive.dart';

import '../../shared/domain/stock_data_state.dart';
import '../domain/inventory_item.dart';
import '../domain/inventory_repository.dart';
import 'inventory_local_data_source.dart';
import 'inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remote;
  final InventoryLocalDataSource local;
  final Box syncBox;

  InventoryRepositoryImpl({
    required this.remote,
    required this.local,
    required this.syncBox,
  });

  @override
  Future<List<InventoryItem>> readLocal(InventoryFilters filters) {
    return local.search(filters);
  }

  @override
  Future<StockDataResult<List<InventoryItem>>> load(
    InventoryFilters filters,
  ) async {
    try {
      final items = await remote.fetch(filters);
      final syncedAt = DateTime.now();
      await local.replace(items, syncedAt);
      await syncBox.put(
        'sync.prioritizedInventory.lastSyncAt',
        syncedAt.toIso8601String(),
      );
      return StockDataResult(
        data: items,
        origin: StockDataOrigin.remote,
        syncedAt: syncedAt,
      );
    } catch (_) {
      final items = await local.search(filters);
      if (items.isEmpty) rethrow;
      final raw = syncBox.get('sync.prioritizedInventory.lastSyncAt');
      return StockDataResult(
        data: items,
        origin: StockDataOrigin.local,
        syncedAt: DateTime.tryParse('${raw ?? ''}'),
      );
    }
  }
}
