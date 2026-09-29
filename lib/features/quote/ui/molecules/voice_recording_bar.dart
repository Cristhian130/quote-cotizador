import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/ia_colors.dart';

class VoiceRecordingBar extends StatefulWidget {
  final Stream<double> levels;
  final VoidCallback onCancel;
  final VoidCallback onStop;

  const VoiceRecordingBar({
    super.key,
    required this.levels,
    required this.onCancel,
    required this.onStop,
  });

  @override
  State<VoiceRecordingBar> createState() => _VoiceRecordingBarState();
}

class _VoiceRecordingBarState extends State<VoiceRecordingBar> {
  final _samples = List<double>.filled(32, 0);
  final _clock = Stopwatch();
  StreamSubscription<double>? _subscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _clock.start();
    _subscription = widget.levels.listen((level) {
      if (!mounted) return;
      setState(() {
        for (var index = 0; index < _samples.length - 1; index++) {
          _samples[index] = _samples[index + 1];
        }
        _samples[_samples.length - 1] = level;
      });
    }, onError: (Object _) {});
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _clock.elapsed.inSeconds;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCEE7D9)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Cancelar audio',
            onPressed: widget.onCancel,
            icon: const Icon(LucideIcons.x, size: 18),
          ),
          const Icon(Icons.fiber_manual_record, size: 10, color: IaColors.destructive),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text('${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final count = (constraints.maxWidth / 7).floor().clamp(1, 32);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _samples.skip(32 - count).map((sample) {
                  return Expanded(
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 3,
                        height: 3 + sample * 27,
                        decoration: BoxDecoration(
                          color: const Color(0xFF21966A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Detener y transcribir',
            onPressed: widget.onStop,
            icon: const Icon(LucideIcons.square, size: 18, color: IaColors.destructive),
          ),
        ],
      ),
    );
  }
}
