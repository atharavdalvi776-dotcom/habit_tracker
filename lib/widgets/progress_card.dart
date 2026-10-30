import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium, visually impressive daily progress card.
///
/// Features:
/// - Rich purple-to-cyan gradient background with glowing drop shadows.
/// - Custom-drawn animated circular progress ring with gradient stroke.
/// - Dynamic motivational messages based on completion level.
/// - Real-time animated counter and percentage readout.
class ProgressCard extends StatelessWidget {
  /// Total number of habits completed today.
  final int completedCount;

  /// Total number of habits registered for today.
  final int totalCount;

  const ProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  double get _fraction {
    if (totalCount == 0) return 0.0;
    return (completedCount / totalCount).clamp(0.0, 1.0);
  }

  String get _motivationalTitle {
    if (totalCount == 0) return 'Begin Your Journey';
    if (_fraction == 1.0) return "You're Crushing It! 🔥";
    if (_fraction >= 0.75) return 'Almost Complete!';
    if (_fraction >= 0.5) return "You're Doing Amazing!";
    if (_fraction > 0) return 'Great Momentum!';
    return 'Ready to Win Today?';
  }

  String get _motivationalSubtitle {
    if (totalCount == 0) {
      return 'Add your first habit below to kick off your streak.';
    }
    if (_fraction == 1.0) {
      return 'Every single habit crushed today. Extraordinary dedication!';
    }
    if (_fraction >= 0.5) {
      return 'More than halfway through your daily goals.';
    }
    if (_fraction > 0) {
      return 'Small wins stack up into massive life achievements.';
    }
    return 'Start with one simple habit and build momentum.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: AppTheme.progressCardGradient,
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purpleDeep.withValues(alpha: 0.4),
            blurRadius: 24.0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.cyanAccent.withValues(alpha: 0.15),
            blurRadius: 16.0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Ambient glowing orb in the background corner
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              children: [
                // Left Column: Text & Statistics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13.0,
                              color: AppTheme.cyanAccent,
                            ),
                            const SizedBox(width: 5.0),
                            const Text(
                              'YOUR DAILY PROGRESS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Motivational Headline
                      Text(
                        _motivationalTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6.0),

                      // Habits completed counter
                      Text(
                        totalCount > 0
                            ? '$completedCount out of $totalCount habits completed'
                            : 'No habits added yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6.0),

                      // Subtitle
                      Text(
                        _motivationalSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12.0,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16.0),

                // Right Column: Custom Animated Circular Progress Ring
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: _fraction),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, child) {
                    return SizedBox(
                      width: 96.0,
                      height: 96.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(96.0, 96.0),
                            painter: _CircularProgressPainter(
                              progress: animatedValue,
                              strokeWidth: 9.0,
                              trackColor: Colors.white.withValues(alpha: 0.15),
                              gradientColors: const [
                                Color(0xFF38BDF8), // Cyan
                                Color(0xFFA855F7), // Purple
                                Color(0xFFF43F5E), // Rose
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(animatedValue * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'DONE',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the gradient circular progress ring.
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final List<Color> gradientColors;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // 2. Draw animated gradient progress arc with rounded caps
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepGradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: gradientColors,
      transform: const GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
