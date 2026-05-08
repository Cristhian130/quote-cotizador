import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/product_provider.dart';
import '../../data/datasources/sqlite_data_source.dart';

const Color _darkBlue = Color(0xFF192D4D);
const Color _medBlue = Color(0xFF233F6A);
const Color _lightBlue = Color(0xFF458AC9);

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────
  late final AnimationController _bgCtrl;
  late final AnimationController _cardCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _barCtrl;
  late final AnimationController _particleCtrl;

  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // ── Sync state ─────────────────────────────────────────
  String _statusLabel = 'Verificando base de datos local...';
  double _progress = 0.0;
  bool _syncError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cardOpacity = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    _logoScale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1. Play entrance animations
    await Future.delayed(const Duration(milliseconds: 80));
    _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    // 2. Verificar cuántos había antes en SQLite (informativo)
    _setStatus('Verificando base de datos local...', 0.05);
    final sqliteDs = SqliteDataSource();
    final countBefore = await sqliteDs.getProductsCount();
    final hasLocal = countBefore > 0;

    // 3. Siempre sincronizar desde el API al iniciar
    _setStatus(
      hasLocal
          ? 'Actualizando inventario desde el servidor...'
          : 'Primera vez — sincronizando inventario desde el servidor...',
      0.10,
    );
    await Future.delayed(const Duration(milliseconds: 300));

    // --- DEV MODE HOT RESTART BYPASS ---
    bool isDevBypass = false;
    if (isDevBypass) {
      if (mounted) widget.onDone();
      return;
    }
    // -----------------------------------

    try {
      final repo = ref.read(productRepositoryProvider);

      _setStatus('Conectando con el servidor...', 0.15);
      _startFakeProgress(
        from: 0.15,
        to: 0.75,
        duration: const Duration(seconds: 30),
      );

      final result = await repo.syncProducts();

      _barCtrl.stop();

      result.fold(
        (failure) async {
          if (hasLocal) {
            // Tenemos datos locales — abrimos igual aunque el sync falló
            _setStatus(
              '⚠️ Sin conexión. Usando inventario local ($countBefore productos).',
              0.85,
            );
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) widget.onDone();
          } else {
            setState(() {
              _syncError = true;
              _progress = 0.0;
              _statusLabel =
                  'Error al sincronizar. Puedes intentarlo más tarde.';
            });
            await Future.delayed(const Duration(seconds: 3));
            if (mounted) widget.onDone();
          }
        },
        (_) async {
          final newCount = await sqliteDs.getProductsCount();
          _setStatus('✓ $newCount productos cargados.', 0.9);
          await Future.delayed(const Duration(milliseconds: 600));
          _setStatus('Iniciando plataforma...', 1.0);
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) widget.onDone();
        },
      );
    } catch (e) {
      if (hasLocal) {
        _setStatus('Sin conexión. Abriendo con inventario local...', 0.85);
        await Future.delayed(const Duration(seconds: 2));
      } else {
        _setStatus('Sin conexión. Abriendo sin inventario...', 0.0);
        await Future.delayed(const Duration(seconds: 2));
      }
      if (mounted) widget.onDone();
    }
  }

  /// Animates progress bar slowly from [from] to [to] over [duration]
  /// without blocking — used while the long API call is in progress.
  void _startFakeProgress({
    required double from,
    required double to,
    required Duration duration,
  }) {
    _progress = from;
    final steps = 60;
    final stepMs = duration.inMilliseconds ~/ steps;
    final increment = (to - from) / steps;
    int step = 0;
    Future.doWhile(() async {
      if (!mounted || step >= steps) return false;
      await Future.delayed(Duration(milliseconds: stepMs));
      if (mounted)
        setState(() => _progress = (_progress + increment).clamp(0, to));
      step++;
      return true;
    });
  }

  void _setStatus(String label, double progress) {
    if (!mounted) return;
    setState(() {
      _statusLabel = label;
      _progress = progress;
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _cardCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _barCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _darkBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated particles
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) =>
                CustomPaint(painter: _ParticlePainter(_particleCtrl.value)),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, 0),
                radius: 1.2,
                colors: [
                  _medBlue.withOpacity(0.85),
                  _darkBlue.withOpacity(0.95),
                ],
              ),
            ),
          ),

          // Center card
          Center(
            child: FadeTransition(
              opacity: _cardOpacity,
              child: SlideTransition(
                position: _cardSlide,
                child: Container(
                  width: min(size.width * 0.55, 620),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _lightBlue.withOpacity(0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 60,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/Banner IA-01.jpg',
                              height: 56,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                height: 56,
                                width: 160,
                                color: _lightBlue.withOpacity(0.3),
                                child: const Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Status + bar
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _statusLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _syncError
                                    ? LinearProgressIndicator(
                                        value: null, // indeterminate on error
                                        minHeight: 5,
                                        backgroundColor: Colors.red.withOpacity(
                                          0.15,
                                        ),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Colors.redAccent,
                                            ),
                                      )
                                    : AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: _progress,
                                          minHeight: 5,
                                          backgroundColor: Colors.white
                                              .withOpacity(0.1),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _lightBlue,
                                              ),
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 10),

                              // Percentage
                              Text(
                                _syncError
                                    ? '⚠️ Error de conexión'
                                    : '${(_progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: _syncError
                                      ? Colors.redAccent
                                      : _lightBlue.withOpacity(0.75),
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Version tag
          Positioned(
            bottom: 20,
            right: 28,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Text(
                'v1.0.7  ·  Importadoras Asociadas',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Particle painter
// ──────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double t;
  static final List<_Particle> _particles = List.generate(
    28,
    (i) => _Particle(i),
  );

  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final progress = (t + p.offset) % 1.0;
      final x = p.startX * size.width;
      final y = size.height - (progress * size.height * 1.15);
      final alpha = (sin(progress * pi) * 0.4).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        p.radius,
        Paint()..color = _lightBlue.withOpacity(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

class _Particle {
  final double startX;
  final double offset;
  final double radius;

  _Particle(int seed)
    : startX = ((seed * 137.508) % 1.0),
      offset = ((seed * 83.3) % 1.0),
      radius = 1.2 + (seed % 5) * 0.6;
}
