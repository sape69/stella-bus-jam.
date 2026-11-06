import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../widgets/game_dialogs.dart';

class GameCompletionService {
  GameCompletionService._();

  static int calculateStars(int mistakes) {
    if (mistakes == 0) {
      return 3;
    }

    if (mistakes <= 2) {
      return 2;
    }

    return 1;
  }

  static Future<void> saveAndShowDialog({
    required BuildContext context,
    required int levelNumber,
    required int stars,
    required int mistakes,
    required VoidCallback onNextLevel,
    required VoidCallback onError,
  }) async {
    try {
      await ProgressService.saveLevelCompletion(
        levelNumber: levelNumber,
        stars: stars,
      );
    } catch (error) {
      onError();
    }

    if (!context.mounted) {
      return;
    }

    GameDialogs.showLevelCompleted(
      context: context,
      stars: stars,
      mistakes: mistakes,
      onNextLevel: onNextLevel,
    );
  }
}