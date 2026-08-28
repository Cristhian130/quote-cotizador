import 'package:hive/hive.dart';

import '../../insights/domain/stock_insight.dart';
import '../../shared/domain/stock_data_state.dart';
import '../domain/business_rule.dart';
import '../domain/rule_evaluation_filters.dart';
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
  Future<StockDataResult<List<BusinessRule>>> load() async {
    try {
      final rules = await remote.fetch();
      final syncedAt = DateTime.now();
      await local.replaceAll(rules);
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
      if (rules.isEmpty) rethrow;
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

  @override
  Future<BusinessRule> create(BusinessRule rule) async {
    final created = await remote.create(rule);
    await local.save(created);
    return created;
  }

  @override
  Future<BusinessRule> update(BusinessRule rule) async {
    final updated = await remote.update(rule);
    await local.save(updated);
    return updated;
  }

  @override
  Future<BusinessRule> toggle(BusinessRule rule) async {
    final updated = await remote.toggle(rule);
    await local.save(updated);
    return updated;
  }

  @override
  Future<void> delete(BusinessRule rule) async {
    await remote.delete(rule);
    await local.delete(rule.id);
  }
}
