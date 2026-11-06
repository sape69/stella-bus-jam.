import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class GameDialogs {
  static Future<bool?> confirmExit(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'EXIT TO HOME?',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to leave this level? '
            'Your current progress in this level will be lost.',
            style: TextStyle(
              color: AppColors.primaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('GO HOME'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> confirmRestart(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'RESTART LEVEL?',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to start this level again? '
            'Your current progress in this level will be lost.',
            style: TextStyle(
              color: AppColors.primaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('RESTART'),
            ),
          ],
        );
      },
    );
  }

  static void showLevelCompleted({
    required BuildContext context,
    required int stars,
    required int mistakes,
    required VoidCallback onNextLevel,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'LEVEL COMPLETED!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEarnedStars(stars),
              const SizedBox(height: 12),
              Text(
                'You earned $stars out of 3 stars!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mistakes: $mistakes',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Great job! All buses and passengers have been cleared.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onNextLevel();
              },
              child: const Text('NEXT LEVEL'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildEarnedStars(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.star_rounded,
            size: 38,
            color: index < stars
                ? AppColors.gold
                : AppColors.secondaryText.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}