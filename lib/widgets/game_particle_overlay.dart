import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ParticleType {
  exitTrail,
  invalidImpact,
  victoryBurst,
  guidanceAura,
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double maxLife;
  double life;
  double opacity;
  double rotation;
  double rotationSpeed;
  ParticleType type;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
    required this.life,
    this.opacity = 1.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    required this.type,
  });

  bool update(double dt) {
    life -= dt;
    if (life <= 0) return false;

    position += velocity * dt * 60;
    opacity = (life / maxLife).clamp(0.0, 1.0);
    rotation += rotationSpeed * dt;

    if (type == ParticleType.exitTrail) {
      velocity *= 0.96;
      size *= 0.97;
    } else if (type == ParticleType.invalidImpact) {
      velocity *= 0.92;
      size *= 0.95;
    } else if (type == ParticleType.victoryBurst) {
      velocity = Offset(velocity.dx * 0.98, velocity.dy * 0.98 + 0.15); // Add light gravity
    }
    return true;
  }
}

class ParticleController extends ChangeNotifier {
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  List<Particle> get particles => List.unmodifiable(_particles);

  void spawnExitTrail(Offset origin, Offset directionVector, Color color) {
    for (int i = 0; i < 16; i++) {
      final angle = math.atan2(directionVector.dy, directionVector.dx) +
          (_random.nextDouble() - 0.5) * 0.6;
      final speed = _random.nextDouble() * 6.0 + 3.0;
      _particles.add(
        Particle(
          position: origin + Offset((_random.nextDouble() - 0.5) * 12, (_random.nextDouble() - 0.5) * 12),
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: _random.nextDouble() * 6.0 + 4.0,
          maxLife: _random.nextDouble() * 0.4 + 0.3,
          life: _random.nextDouble() * 0.4 + 0.3,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 5.0,
          type: ParticleType.exitTrail,
        ),
      );
    }
    notifyListeners();
  }

  void spawnInvalidImpact(Offset origin) {
    final colors = [Colors.redAccent, Colors.deepOrange, Colors.orangeAccent];
    for (int i = 0; i < 18; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = _random.nextDouble() * 7.0 + 2.0;
      _particles.add(
        Particle(
          position: origin,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: colors[_random.nextInt(colors.length)],
          size: _random.nextDouble() * 7.0 + 3.0,
          maxLife: _random.nextDouble() * 0.3 + 0.2,
          life: _random.nextDouble() * 0.3 + 0.2,
          type: ParticleType.invalidImpact,
        ),
      );
    }
    notifyListeners();
  }

  void spawnVictoryBurst(Size screenSize) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF4500), // OrangeRed
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFF76FF03), // Lime
      const Color(0xFFE040FB), // Purple Accent
    ];
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 3;

    for (int i = 0; i < 60; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = _random.nextDouble() * 12.0 + 4.0;
      _particles.add(
        Particle(
          position: Offset(centerX + (_random.nextDouble() - 0.5) * 40, centerY + (_random.nextDouble() - 0.5) * 40),
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: colors[_random.nextInt(colors.length)],
          size: _random.nextDouble() * 8.0 + 4.0,
          maxLife: _random.nextDouble() * 0.8 + 0.5,
          life: _random.nextDouble() * 0.8 + 0.5,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 6.0,
          type: ParticleType.victoryBurst,
        ),
      );
    }
    notifyListeners();
  }

  void update(double dt) {
    if (_particles.isEmpty) return;
    _particles.removeWhere((p) => !p.update(dt));
    notifyListeners();
  }

  void clear() {
    _particles.clear();
    notifyListeners();
  }
}

class GameParticleOverlay extends StatefulWidget {
  final ParticleController controller;
  final Widget child;

  const GameParticleOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<GameParticleOverlay> createState() => _GameParticleOverlayState();
}

class _GameParticleOverlayState extends State<GameParticleOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _ticker.addListener(_onFrame);
  }

  void _onFrame() {
    final now = DateTime.now();
    final dt = (now.difference(_lastTime).inMilliseconds / 1000.0).clamp(0.001, 0.05);
    _lastTime = now;
    widget.controller.update(dt);
  }

  @override
  void dispose() {
    _ticker.removeListener(_onFrame);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(particles: widget.controller.particles),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.rotation);

      if (p.type == ParticleType.victoryBurst) {
        // Draw star shape for victory burst
        final path = Path();
        final radius = p.size;
        for (int i = 0; i < 5; i++) {
          final outerAngle = (i * 72 - 90) * math.pi / 180;
          final innerAngle = ((i * 72 + 36) - 90) * math.pi / 180;
          final x1 = math.cos(outerAngle) * radius;
          final y1 = math.sin(outerAngle) * radius;
          final x2 = math.cos(innerAngle) * (radius * 0.4);
          final y2 = math.sin(innerAngle) * (radius * 0.4);
          if (i == 0) {
            path.moveTo(x1, y1);
          } else {
            path.lineTo(x1, y1);
          }
          path.lineTo(x2, y2);
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        // Draw soft glowing circle
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
