
import '../models/level.dart';
import 'level_generation/level_builder.dart';

class LevelService {
  LevelService._();

  static Level createLevel(int levelNumber) {
    return LevelBuilder.build(levelNumber);
  }
}
