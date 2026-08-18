import 'package:hive/hive.dart';

import '../../shared/domain/stock_data_state.dart';
import '../domain/insights_repository.dart';
import '../domain/stock_insight.dart';
import 'insights_local_data_source.dart';
import 'insights_remote_data_source.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  final InsightsRemoteDataSource remote;
  final InsightsLocalDataSource local;
  final Box syncBox;

  InsightsRepositoryImpl({
    required this.remote,
    required this.local,
    required this.syncBox,
  });

  @override
  Future<InsightPage> readLocal(InsightFilters filters) => local.search(filters);

  @override
  Future<StockDataResult<InsightPage>> load(InsightFilters filters) async {
    try {
      final page = await remote.fetch(filters);
      final syncedAt = DateTime.now();
      final previousRun = '${syncBox.get('sync.rotation.activeRunId') ?? ''}';
      await local.replacePage(
        page,
        syncedAt,
        clearPreviousRun: previousRun != page.runId,
      );
      await syncBox.putAll({
        'sync.rotation.activeRunId': page.runId,
        'sync.rotation.lastSyncAt': syncedAt.toIso8601String(),
        'sync.rotation.nextCursor': page.nextCursor,
        'sync.rotation.syncComplete': page.nextCursor == null,
      });
      return StockDataResult(
        data: page,
        origin: StockDataOrigin.remote,
        syncedAt: syncedAt,
      );
    } catch (_) {
      final page = await local.search(filters);
      if (page.items.isEmpty) rethrow;
      final raw = syncBox.get('sync.rotation.lastSyncAt');
      return StockDataResult(
        data: page,
        origin: StockDataOrigin.local,
        syncedAt: DateTime.tryParse('${raw ?? ''}'),
      );
    }
  }
}
