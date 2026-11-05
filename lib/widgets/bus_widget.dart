
import 'package:flutter/material.dart';

import '../models/bus.dart';

class BusWidget extends StatelessWidget {
  final Bus bus;
  final VoidCallback? onTap;

  const BusWidget({
    super.key,
    required this.bus,
    this.onTap,
  });

  IconData _exitArrow() {
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
    final isHorizontal =
        bus.direction == BusDirection.horizontal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bus.color,
              bus.color.withValues(alpha: 0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Flex(
          direction:
              isHorizontal ? Axis.horizontal : Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
            Icon(
              _exitArrow(),
              color: Colors.white,
              size: 24,
            ),
            Text(
              '${bus.passengers}/${bus.capacity}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
