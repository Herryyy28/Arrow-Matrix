import 'dart:math' as math;
import 'package:flutter/material.dart';

class GameEnvironmentWidget extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const GameEnvironmentWidget({
    super.key,
    required this.child,
    this.isDark = true,
  });

  @override
  State<GameEnvironmentWidget> createState() => _GameEnvironmentWidgetState();
}

class _GameEnvironmentWidgetState extends State<GameEnvironmentWidget> with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, _) {
        final progress = _bgAnimController.value;
        final isDark = widget.isDark;

        final bgGradient = isDark
            ? LinearGradient(
                begin: Alignment(-0.8 + math.sin(progress * math.pi) * 0.3, -1.0),
                end: Alignment(0.8 + math.cos(progress * math.pi) * 0.3, 1.0),
                colors: const [
                  Color(0xFF090D16),
                  Color(0xFF05050A),
                  Color(0xFF10172A),
                ],
              )
            : LinearGradient(
                begin: Alignment(-0.8 + math.sin(progress * math.pi) * 0.3, -1.0),
                end: Alignment(0.8 + math.cos(progress * math.pi) * 0.3, 1.0),
                colors: const [
                  Color(0xFFF1F5F9),
                  Color(0xFFE2E8F0),
                  Color(0xFFCBD5E1),
                ],
              );

        return Stack(
          children: [
            // Layer 1: Dynamic Animated Gradient Background
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(gradient: bgGradient),
              ),
            ),

            // Layer 2: 3D Spotlight Illumination behind Board
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SpotlightPainter(
                    progress: progress,
                    isDark: isDark,
                  ),
                ),
              ),
            ),

            // Layer 3: Foreground Content (Board & HUD)
            Positioned.fill(
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SpotlightPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final radius = size.width * 0.75;

    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isDark
              ? const Color(0xFF6366F1).withValues(alpha: 0.18 + math.sin(progress * math.pi) * 0.06)
              : const Color(0xFF3B82F6).withValues(alpha: 0.12),
          isDark
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.08)
              : const Color(0xFF60A5FA).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, spotlightPaint);

    // Subtle 3D Grid Lines Perspective Pattern
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    final spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
