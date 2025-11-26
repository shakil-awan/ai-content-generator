import 'package:flutter/material.dart';

import '../models/quality_score.dart';

/// Quality Score Badge Widget
/// Displays circular badge with quality grade
class QualityScoreBadge extends StatefulWidget {
  final QualityScore qualityScore;
  final VoidCallback? onTap;
  final double size;

  const QualityScoreBadge({
    super.key,
    required this.qualityScore,
    this.onTap,
    this.size = 60,
  });

  @override
  State<QualityScoreBadge> createState() => _QualityScoreBadgeState();
}

class _QualityScoreBadgeState extends State<QualityScoreBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grade = widget.qualityScore.grade;
    final color = widget.qualityScore.gradeColor;
    final bgColor = widget.qualityScore.gradeBackgroundColor;
    final percentage = widget.qualityScore.percentage;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Tooltip(
          message: 'Quality Score: $grade ($percentage%)',
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Grade
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: widget.size * 0.4, // 24px for 60px badge
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  // Label
                  Text(
                    'Quality',
                    style: TextStyle(
                      fontSize: widget.size * 0.16, // 10px for 60px badge
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
