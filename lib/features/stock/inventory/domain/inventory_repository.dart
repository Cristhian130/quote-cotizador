import '../../shared/domain/stock_data_state.dart';
import 'inventory_item.dart';

abstract class InventoryRepository {
  Future<StockDataResult<List<InventoryItem>>> load(InventoryFilters filters);
  Future<List<InventoryItem>> readLocal(InventoryFilters filters);
}
