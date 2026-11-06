
import 'package:flutter/material.dart';

import '../models/bus.dart';

/// Animates a bus from the game board into its parking slot.
///
/// The animation uses coordinates and sizes supplied by GamePage.
/// It does not create or control its own AnimationController.
class BusParkingAnimation extends StatelessWidget {
  final Bus bus;
  final Animation<double> animation;
  final Offset start;
  final Offset end;
  final Size startSize;
  final Size endSize;

  const BusParkingAnimation({
    super.key,
    required this.bus,
    required this.animation,
    required this.start,
    required this.end,
    required this.startSize,
    required this.endSize,
  });

  IconData get _exitArrow {
    switch (bus.exitDirection) {
      case BusExitDirection.up:
        return Icons.arrow_upward_rounded;
      case BusExitDirection.down:
        return Icons.arrow_downward_rounded;
      case BusExitDirection.left:
        return Icons.arrow_back_rounded;
      case BusExitDirection.right:
        return Icons.arrow_forward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = Curves.easeInOutCubic.transform(
          animation.value.clamp(0.0, 1.0),
        );

        final position = Offset.lerp(
          start,
          end,
          progress,
        )!;

        final size = Size.lerp(
          startSize,
          endSize,
          progress,
        )!;

        final parkingProgress =
            ((progress - 0.72) / 0.28).clamp(0.0, 1.0);

        final arrowOpacity = 1.0 - parkingProgress;
        final busIconOpacity = parkingProgress;

        final borderRadius = BorderRadius.lerp(
          BorderRadius.circular(9),
          BorderRadius.circular(22),
          parkingProgress,
        )!;

        final iconSize = 25.0 * (size.shortestSide / 43)
            .clamp(0.65, 1.5);

        return Positioned(
          left: position.dx - size.width / 2,
          top: position.dy - size.height / 2,
          width: size.width,
          height: size.height,
          child: IgnorePointer(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    bus.color,
                    bus.color.withValues(alpha: 0.78),
                  ],
                ),
                borderRadius: borderRadius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: bus.color.withValues(alpha: 0.28),
                    blurRadius: 9,
                    offset: const Offset(2, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 5,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: arrowOpacity,
                    child: Icon(
                      _exitArrow,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                  Opacity(
                    opacity: busIconOpacity,
                    child: Icon(
                      Icons.directions_bus_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
