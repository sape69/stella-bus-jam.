import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class GameHeader extends StatelessWidget {
  final int levelNumber;
  final int passengersLeft;
  final int busesLeft;
  final int mistakes;

  final VoidCallback onBack;
  final VoidCallback onRestart;

  const GameHeader({
    super.key,
    required this.levelNumber,
    required this.passengersLeft,
    required this.busesLeft,
    required this.mistakes,
    required this.onBack,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildLevelInfo(),
        _buildStarProgress(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Back to home',
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.purple,
              size: 27,
            ),
          ),
          const Icon(
            Icons.pets,
            color: AppColors.pink,
            size: 30,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'STELLA BUS JAM',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onRestart,
            tooltip: 'Restart level',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.pink,
              size: 27,
            ),
          ),
          _buildLevelBadge(),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.purple,
        ),
      ),
      child: Text(
        'LEVEL $levelNumber',
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLevelInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_alt_rounded,
            color: AppColors.pink,
            size: 19,
          ),
          const SizedBox(width: 7),
          Text(
            '$passengersLeft PASSENGERS LEFT',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '$busesLeft BUSES LEFT',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.gold,
            size: 20,
          ),
          const SizedBox(width: 6),
          const Text(
            'MISTAKES:',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$mistakes',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          const Text(
            '3 STARS POSSIBLE',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}