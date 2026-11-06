import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class PassengerAnimation extends StatelessWidget {
  final Animation<double> animation;
  final Offset? start;
  final Offset? end;
  final Color? passengerColor;
  final double arc;

  const PassengerAnimation({
    super.key,
    required this.animation,
    required this.start,
    required this.end,
    required this.passengerColor,
    this.arc = 55,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = Curves.easeInOutCubic.transform(
          animation.value,
        );

        final startPosition = start ?? Offset.zero;
        final endPosition = end ?? Offset.zero;

        final position = Offset.lerp(
          startPosition,
          endPosition,
          progress,
        )!;

        final animationArc =
            math.sin(progress * math.pi) * arc;

        final scale = 1.0 - (progress * 0.12);

        return Positioned(
          left: position.dx - 17,
          top: position.dy - 17 - animationArc,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: _buildPassenger(),
    );
  }

  Widget _buildPassenger() {
    final color = passengerColor ?? AppColors.purple;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}