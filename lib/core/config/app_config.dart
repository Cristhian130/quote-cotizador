import 'package:hive/hive.dart';

/// Manages the active backend base URL.
/// Persists the selection across app restarts via Hive.
class AppConfig {
  static const _boxName = 'app_config';
  static const _keyBaseUrl = 'base_url';
  static const _keySellerName = 'seller_name';
  static const _keyQuoteCounter = 'quote_counter';

  static const String localUrl = 'http://localhost:3001';
  static const String ngrokUrl = 'http://172.191.47.164:1466';

  static final List<String> presets = [ngrokUrl, localUrl];

  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Returns the currently active base URL.
  static String get baseUrl =>
      _box.get(_keyBaseUrl, defaultValue: ngrokUrl) as String;

  /// Saves a new base URL (must end without trailing slash).
  static Future<void> setBaseUrl(String url) async {
    final clean = url.trimRight().replaceAll(RegExp(r'/$'), '');
    await _box.put(_keyBaseUrl, clean);
  }

  /// Seller Name persistence
  static String get sellerName => _box.get(_keySellerName, defaultValue: '') as String;
  static Future<void> setSellerName(String name) async => await _box.put(_keySellerName, name);

  /// Quote Counter persistence (Sequential COT-001, etc)
  static int get quoteCounter => _box.get(_keyQuoteCounter, defaultValue: 1) as int;
  static Future<void> incrementQuoteCounter() async => await _box.put(_keyQuoteCounter, quoteCounter + 1);
}
