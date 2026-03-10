import 'package:hive/hive.dart';

/// Manages the active backend base URL.
/// Persists the selection across app restarts via Hive.
class AppConfig {
  static const _boxName = 'app_config';
  static const _keyBaseUrl = 'base_url';

  static const String localUrl = 'http://localhost:3001';
  static const String ngrokUrl =
      'https://options-cia-joyce-philips.trycloudflare.com';

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
}
