import '../../insights/domain/stock_insight.dart';
import '../../shared/domain/stock_data_state.dart';
import 'business_rule.dart';
import 'rule_evaluation_filters.dart';

abstract class RulesRepository {
  Future<StockDataResult<List<BusinessRule>>> load();
  Future<InsightPage> evaluate(RuleEvaluationFilters filters);
  Future<BusinessRule> create(BusinessRule rule);
  Future<BusinessRule> update(BusinessRule rule);
  Future<BusinessRule> toggle(BusinessRule rule);
  Future<void> delete(BusinessRule rule);
}
