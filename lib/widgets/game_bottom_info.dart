import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class GameBottomInfo extends StatelessWidget {
  const GameBottomInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.gold,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Guide the buses out and collect the passengers!',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}