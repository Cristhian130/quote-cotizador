import '../../insights/domain/stock_insight.dart';
import '../../shared/domain/stock_data_state.dart';
import 'alert_rules.dart';

abstract class RulesRepository {
  Future<StockDataResult<AlertRules>> load();
  Future<InsightPage> evaluate(RuleEvaluationFilters filters);
}
