import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'core/theme/ia_colors.dart';
import 'features/quote/ui/pages/quote_page.dart';
import 'features/quote/ui/pages/splash_screen.dart';
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
  bool _splashDone = false;

  void _onSplashDone() {
    setState(() => _splashDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(onDone: _onSplashDone);
    }
    return const QuotePage();
  }
}
