import 'package:hive/hive.dart';

import '../../insights/domain/stock_insight.dart';
import '../../shared/domain/stock_data_state.dart';
import '../domain/alert_rules.dart';
import '../domain/rules_repository.dart';
import 'rules_local_data_source.dart';
import 'rules_remote_data_source.dart';

class RulesRepositoryImpl implements RulesRepository {
  final RulesRemoteDataSource remote;
  final RulesLocalDataSource local;
  final Box syncBox;

  RulesRepositoryImpl({
    required this.remote,
    required this.local,
    required this.syncBox,
  });

  @override
  Future<StockDataResult<AlertRules>> load() async {
    try {
      final rules = await remote.fetch();
      final syncedAt = DateTime.now();
      await local.save(rules, syncedAt);
      await syncBox.put(
        'sync.alertRules.lastSyncAt',
        syncedAt.toIso8601String(),
      );
      return StockDataResult(
        data: rules,
        origin: StockDataOrigin.remote,
        syncedAt: syncedAt,
      );
    } catch (_) {
      final rules = await local.read();
      if (rules == null) rethrow;
      final raw = syncBox.get('sync.alertRules.lastSyncAt');
      return StockDataResult(
        data: rules,
        origin: StockDataOrigin.local,
        syncedAt: DateTime.tryParse('${raw ?? ''}'),
      );
    }
  }

  @override
  Future<InsightPage> evaluate(RuleEvaluationFilters filters) {
    return remote.evaluate(filters);
  }
}
