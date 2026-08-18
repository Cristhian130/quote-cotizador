import '../../shared/domain/stock_data_state.dart';
import 'stock_insight.dart';

abstract class InsightsRepository {
  Future<StockDataResult<InsightPage>> load(InsightFilters filters);
  Future<InsightPage> readLocal(InsightFilters filters);
}
