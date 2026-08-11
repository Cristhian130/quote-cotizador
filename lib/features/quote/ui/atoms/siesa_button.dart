import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;

class SiesaButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const SiesaButton({
    super.key,
    required this.onPressed,
    this.text = 'Envía a Siesa y genera tu pedido',
  });

  @override
  State<SiesaButton> createState() => _SiesaButtonState();
}

class _SiesaButtonState extends State<SiesaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4 + 0.2 * math.sin(_controller.value * 2 * math.pi)),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _BorderDazzlePainter(animationValue: _controller.value),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [
                        Color(0xFFFF8C00),
                        Color(0xFFFF4500),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      transform: GradientRotation(_controller.value * 2 * math.pi),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.zap,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BorderDazzlePainter extends CustomPainter {
  final double animationValue;

  _BorderDazzlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          Colors.orange.shade200,
          Colors.white,
          Colors.orange.shade200,
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(rrect, paint);
    
    // Spark animation around the border
    final sparkPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    // Calculate spark position based on animation progress
    double totalLength = (size.width + size.height) * 2;
    double currentPos = animationValue * totalLength;
    
    Offset sparkPos;
    if (currentPos < size.width) {
      sparkPos = Offset(currentPos, 0);
    } else if (currentPos < size.width + size.height) {
      sparkPos = Offset(size.width, currentPos - size.width);
    } else if (currentPos < size.width * 2 + size.height) {
      sparkPos = Offset(size.width - (currentPos - (size.width + size.height)), size.height);
    } else {
      sparkPos = Offset(0, size.height - (currentPos - (size.width * 2 + size.height)));
    }
    
    canvas.drawCircle(sparkPos, 4, sparkPaint);
  }

  @override
  bool shouldRepaint(_BorderDazzlePainter oldDelegate) => 
    oldDelegate.animationValue != animationValue;
}
