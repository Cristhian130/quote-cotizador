import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveDatabase {
  static const String productBoxName = 'product_cache';
  static const String syncBoxName = 'sync_meta';

  static Future<void> init() async {
    await Hive.initFlutter();

    await _openBoxSafely(productBoxName);
    // Caja para almacenar metadatos adicionales, como la hora de última sincronización
    await _openBoxSafely(syncBoxName);
  }

  static Future<Box> _openBoxSafely(String name) async {
    try {
      return await Hive.openBox(name);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error al abrir caja Hive "$name": $e. Limpiando y recreando caja...');
      }
      try {
        if (Hive.isBoxOpen(name)) {
          await Hive.box(name).close();
        }
      } catch (_) {}

      try {
        await Hive.deleteBoxFromDisk(name);
      } catch (_) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          for (final ext in ['.hive', '.hivec', '.lock']) {
            final file = File('${dir.path}/$name$ext');
            if (file.existsSync()) {
              try {
                file.deleteSync();
              } catch (_) {}
            }
          }
        } catch (_) {}
      }

      try {
        return await Hive.openBox(name);
      } catch (e2) {
        if (kDebugMode) {
          print('⚠️ No se pudo reabrir "$name" ($e2). Creando caja alternativa...');
        }
        final fallbackName = '${name}_clean';
        try {
          await Hive.deleteBoxFromDisk(fallbackName);
        } catch (_) {}
        return await Hive.openBox(fallbackName);
      }
    }
  }

  static Box get productBox {
    if (Hive.isBoxOpen(productBoxName)) {
      return Hive.box(productBoxName);
    }
    return Hive.box('${productBoxName}_clean');
  }

  static Box get syncBox {
    if (Hive.isBoxOpen(syncBoxName)) {
      return Hive.box(syncBoxName);
    }
    return Hive.box('${syncBoxName}_clean');
  }
}
