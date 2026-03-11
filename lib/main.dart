import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'core/theme/ia_colors.dart';
import 'features/quote/ui/pages/quote_page.dart';
import 'features/quote/ui/pages/splash_screen.dart';
import 'features/home/ui/home_screen.dart';
import 'features/stock/ui/stock_screen.dart';
import 'core/config/app_config.dart';

import 'core/database/hive_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await HiveDatabase.init();
  await AppConfig.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IA Cotizador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: IaColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: IaColors.primary,
          primary: IaColors.primary,
          secondary: IaColors.accent,
          surface: IaColors.card,
        ),
      ),
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  _Screen _screen = _Screen.home; // HomeScreen is the entry point

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      _Screen.home => HomeScreen(
        onNavigateToVentas: () => setState(() => _screen = _Screen.splash),
        onNavigateToStock: () => setState(() => _screen = _Screen.stock),
      ),
      // SplashScreen (inventory sync) only runs when entering Ventas
      _Screen.splash => SplashScreen(
        onDone: () => setState(() => _screen = _Screen.ventas),
      ),
      _Screen.ventas => const QuotePage(),
      _Screen.stock => StockScreen(
        onBack: () => setState(() => _screen = _Screen.home),
      ),
    };
  }
}

enum _Screen { home, splash, ventas, stock }
