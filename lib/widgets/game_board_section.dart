
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/bus.dart';
import 'game_board.dart';

class GameBoardSection extends StatelessWidget {
  final int boardSize;
  final List<Bus> buses;
  final ValueChanged<Bus> onBusTap;
  final bool Function(Bus) canBusMove;
  final Map<String, GlobalKey>? busAnchorKeys;

  const GameBoardSection({
    super.key,
    required this.boardSize,
    required this.buses,
    required this.onBusTap,
    required this.canBusMove,
    this.busAnchorKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 4,
              bottom: 10,
            ),
            child: Text(
              'BUS PUZZLE',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          GameBoard(
            boardSize: boardSize,
            buses: buses,
            onBusTap: onBusTap,
            canBusMove: canBusMove,
            busAnchorKeys: busAnchorKeys,
          ),
        ],
      ),
    );
  }
}
