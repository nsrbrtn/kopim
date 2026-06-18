import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GettingStartedCelebrationDialog extends StatefulWidget {
  const GettingStartedCelebrationDialog({super.key});

  @override
  State<GettingStartedCelebrationDialog> createState() =>
      _GettingStartedCelebrationDialogState();
}

class _GettingStartedCelebrationDialogState
    extends State<GettingStartedCelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final Animation<double> _confettiAnimation;
  List<_ConfettiParticle>? _particles;

  late final AnimationController _entranceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Анимация полета конфетти (1.8 секунды)
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _confettiAnimation =
        CurvedAnimation(parent: _confettiController, curve: Curves.easeOutCubic)
          ..addListener(() {
            setState(() {});
          });

    // Анимация появления самого диалога (400 мс)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeIn),
    );

    // Запуск анимаций
    _entranceController.forward();
    _confettiController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations strings = AppLocalizations.of(context)!;

    if (_particles == null) {
      final math.Random rand = math.Random();
      final List<Color> brandColors = <Color>[
        colors.primary,
        colors.secondary,
        colors.tertiary,
        colors.primaryContainer,
        colors.tertiaryContainer,
      ];
      _particles = List<_ConfettiParticle>.generate(
        60,
        (int index) => _ConfettiParticle.random(rand, brandColors),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          // Область с конфетти (на весь размер контейнера диалога)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles!,
                  progress: _confettiAnimation.value,
                ),
              ),
            ),
          ),
          // Карточка с информацией
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                    context.kopimLayout.radius.card,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        _GlowRing(color: colors.primary),
                        _RotatingRay(
                          color: colors.tertiary.withValues(alpha: 0.15),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: 44,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.gettingStartedCelebrationTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.gettingStartedCelebrationSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(strings.gettingStartedCelebrationButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowRing extends StatefulWidget {
  const _GlowRing({required this.color});

  final Color color;

  @override
  State<_GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<_GlowRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              widget.color.withValues(alpha: 0.35),
              widget.color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _RotatingRay extends StatefulWidget {
  const _RotatingRay({required this.color});

  final Color color;

  @override
  State<_RotatingRay> createState() => _RotatingRayState();
}

class _RotatingRayState extends State<_RotatingRay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: const Size(120, 120),
        painter: _RayPainter(color: widget.color),
      ),
    );
  }
}

class _RayPainter extends CustomPainter {
  _RayPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    const int rayCount = 8;
    const double rayAngle = (2 * math.pi) / rayCount;

    for (int i = 0; i < rayCount; i++) {
      final double startAngle = i * rayAngle;
      final double endAngle = startAngle + (rayAngle / 2);

      final Path path = Path()
        ..moveTo(centerX, centerY)
        ..arcTo(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
          startAngle,
          endAngle - startAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RayPainter oldDelegate) => false;
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.isCircle,
    required this.rotation,
    required this.rotationSpeed,
    required this.gravity,
  });

  factory _ConfettiParticle.random(math.Random rand, List<Color> colors) {
    final double angle = rand.nextDouble() * 2 * math.pi;
    final double speed = 100.0 + rand.nextDouble() * 150.0;
    return _ConfettiParticle(
      vx: math.cos(angle) * speed,
      vy: math.sin(angle) * speed - 50.0, // легкое смещение вверх при взрыве
      color: colors[rand.nextInt(colors.length)],
      size: 5.0 + rand.nextDouble() * 8.0,
      isCircle: rand.nextBool(),
      rotation: rand.nextDouble() * 2 * math.pi,
      rotationSpeed: (rand.nextDouble() - 0.5) * 8.0,
      gravity: 120.0 + rand.nextDouble() * 100.0,
    );
  }

  final double vx;
  final double vy;
  final Color color;
  final double size;
  final bool isCircle;
  final double rotation;
  final double rotationSpeed;
  final double gravity;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    for (final _ConfettiParticle p in particles) {
      final double t = progress;
      final double x = centerX + p.vx * t;
      final double y = centerY + p.vy * t + 0.5 * p.gravity * t * t;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);
      paint.color = p.color.withValues(alpha: (1.0 - t).clamp(0.0, 1.0));

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
