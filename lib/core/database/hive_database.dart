import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  static const String productBoxName = 'product_cache';
  static const String syncBoxName = 'sync_meta';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(productBoxName);
    // Caja para almacenar metadatos adicionales, como la hora de última sincronización
    await Hive.openBox(syncBoxName);
  }

  static Box get productBox => Hive.box(productBoxName);
  static Box get syncBox => Hive.box(syncBoxName);
}
