
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/bus.dart';

class GameBoard extends StatelessWidget {
  final int boardSize;
  final List<Bus> buses;
  final ValueChanged<Bus>? onBusTap;

  const GameBoard({
    super.key,
    this.boardSize = 8,
    this.buses = const [],
    this.onBusTap,
  });

  IconData _exitArrow(Bus bus) {
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
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.board,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.boardBorder,
            width: 2,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize =
                constraints.maxWidth / boardSize;

            return Stack(
              children: [
                _buildGrid(),
                ...buses.map(
                  (bus) => _buildBus(bus, cellSize),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: List.generate(
        boardSize,
        (row) => Expanded(
          child: Row(
            children: List.generate(
              boardSize,
              (column) => Expanded(
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: AppColors.boardCell,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBus(Bus bus, double cellSize) {
    final isHorizontal =
        bus.direction == BusDirection.horizontal;

    final width = isHorizontal
        ? cellSize * bus.length
        : cellSize;

    final height = isHorizontal
        ? cellSize
        : cellSize * bus.length;

    return Positioned(
      left: bus.column * cellSize,
      top: bus.row * cellSize,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => onBusTap?.call(bus),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bus.color,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _exitArrow(bus),
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}
