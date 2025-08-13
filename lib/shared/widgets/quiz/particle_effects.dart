import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_colors.dart';
import '../../constants/app_animations.dart';

/// Particle effects for correct answers and celebrations
/// Reference: docs/ui_guideline.md - Visual Feedback Colors
class ParticleEffects extends StatefulWidget {
  final bool isActive;
  final ParticleType type;
  final int particleCount;
  final Duration duration;
  final VoidCallback? onComplete;

  const ParticleEffects({
    super.key,
    required this.isActive,
    this.type = ParticleType.confetti,
    this.particleCount = AppAnimations.confettiParticleCount,
    this.duration = AppAnimations.confettiDuration,
    this.onComplete,
  });

  @override
  State<ParticleEffects> createState() => _ParticleEffectsState();
}

class _ParticleEffectsState extends State<ParticleEffects>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _generateParticles();
  }

  void _setupAnimation() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        if (mounted) {
          _controller.reset();
        }
      }
    });
  }

  void _generateParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        color: _getRandomColor(random),
        initialX: random.nextDouble(),
        initialY: random.nextDouble(),
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: -random.nextDouble() * 2 - 1,
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        shape:
            ParticleShape.values[random.nextInt(ParticleShape.values.length)],
      );
    });
  }

  Color _getRandomColor(math.Random random) {
    switch (widget.type) {
      case ParticleType.confetti:
        final colors = [
          AppColors.vibrantPurple,
          AppColors.turquoise,
          AppColors.coralRed,
          AppColors.mintGreen,
          AppColors.warmYellow,
        ];
        return colors[random.nextInt(colors.length)];
      case ParticleType.stars:
        return AppColors.achievement;
      case ParticleType.hearts:
        return AppColors.coralRed;
      case ParticleType.success:
        return AppColors.success;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ParticleEffects oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _generateParticles();
      _controller.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            gravity: AppAnimations.confettiGravity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Individual particle data
class Particle {
  final Color color;
  final double initialX;
  final double initialY;
  final double velocityX;
  final double velocityY;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final ParticleShape shape;

  Particle({
    required this.color,
    required this.initialX,
    required this.initialY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

/// Particle painter for custom rendering
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final double gravity;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.gravity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      // Calculate position with physics
      final x =
          size.width * particle.initialX +
          particle.velocityX * progress * size.width;
      final y =
          size.height * particle.initialY +
          particle.velocityY * progress * size.height +
          0.5 * gravity * progress * progress * size.height;

      // Calculate rotation
      final currentRotation =
          particle.rotation + particle.rotationSpeed * progress * 2 * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      // Draw particle based on shape
      switch (particle.shape) {
        case ParticleShape.circle:
          canvas.drawCircle(Offset.zero, particle.size, paint);
          break;
        case ParticleShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 2,
              height: particle.size * 2,
            ),
            paint,
          );
          break;
        case ParticleShape.star:
          _drawStar(canvas, paint, particle.size);
          break;
        case ParticleShape.heart:
          _drawHeart(canvas, paint, particle.size);
          break;
        case ParticleShape.triangle:
          _drawTriangle(canvas, paint, particle.size);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    const int points = 5;
    final double outerRadius = size;
    final double innerRadius = size * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final double angle = (i * math.pi / points) - math.pi / 2;
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double x = math.cos(angle) * radius;
      final double y = math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final double scale = size / 10;

    path.moveTo(0, 3 * scale);
    path.cubicTo(-3 * scale, 0, -6 * scale, 0, -6 * scale, 3 * scale);
    path.cubicTo(-6 * scale, 6 * scale, 0, 9 * scale, 0, 12 * scale);
    path.cubicTo(0, 9 * scale, 6 * scale, 6 * scale, 6 * scale, 3 * scale);
    path.cubicTo(6 * scale, 0, 3 * scale, 0, 0, 3 * scale);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(-size, size);
    path.lineTo(size, size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Types of particle effects
enum ParticleType { confetti, stars, hearts, success }

/// Particle shapes
enum ParticleShape { circle, square, star, heart, triangle }

/// Pre-configured particle effects for common use cases
class SuccessParticles extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onComplete;

  const SuccessParticles({super.key, required this.isActive, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return ParticleEffects(
      isActive: isActive,
      type: ParticleType.success,
      particleCount: 30,
      duration: const Duration(milliseconds: 2000),
      onComplete: onComplete,
    );
  }
}

class ConfettiParticles extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onComplete;

  const ConfettiParticles({super.key, required this.isActive, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return ParticleEffects(
      isActive: isActive,
      type: ParticleType.confetti,
      particleCount: AppAnimations.confettiParticleCount,
      duration: AppAnimations.confettiDuration,
      onComplete: onComplete,
    );
  }
}

class StarParticles extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onComplete;

  const StarParticles({super.key, required this.isActive, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return ParticleEffects(
      isActive: isActive,
      type: ParticleType.stars,
      particleCount: 20,
      duration: const Duration(milliseconds: 1500),
      onComplete: onComplete,
    );
  }
}
