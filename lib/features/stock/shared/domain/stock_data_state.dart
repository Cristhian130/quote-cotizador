enum StockDataOrigin { remote, local }

class StockDataResult<T> {
  final T data;
  final StockDataOrigin origin;
  final DateTime? syncedAt;

  const StockDataResult({
    required this.data,
    required this.origin,
    this.syncedAt,
  });

  bool get isLocal => origin == StockDataOrigin.local;
}
