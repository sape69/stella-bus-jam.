import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: _buildWelcomeContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pets,
            color: AppColors.pink,
            size: 30,
          ),
          const SizedBox(width: 10),
          const Text(
            'STELLA BUS JAM',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          _buildLevelBadge(),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.purple,
        ),
      ),
      child: const Text(
        'LEVEL 1',
        style: TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.directions_bus_rounded,
          size: 90,
          color: AppColors.purple,
        ),
        const SizedBox(height: 20),
        const Text(
          'STELLA BUS JAM',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Get the passengers on the right buses!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(
          color: AppColors.pink,
        ),
      ],
    );
  }
}