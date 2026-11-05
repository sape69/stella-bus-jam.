import 'package:flutter/material.dart';

import '../models/bus.dart';
import '../models/customer.dart';
import '../models/level.dart';

class LevelService {
  LevelService._();

  static Level createLevel(int levelNumber) {
    final colors = _getLevelColors();

    final buses = [
      Bus(
        id: 'bus_1',
        color: colors[0],
        capacity: 5,
        direction: BusDirection.horizontal,
        row: 0,
        column: 0,
        length: 2,
      ),
      Bus(
        id: 'bus_2',
        color: colors[1],
        capacity: 10,
        direction: BusDirection.vertical,
        row: 1,
        column: 3,
        length: 3,
      ),
      Bus(
        id: 'bus_3',
        color: colors[2],
        capacity: 15,
        direction: BusDirection.horizontal,
        row: 4,
        column: 1,
        length: 4,
      ),
    ];

    final queueA = _createQueue(
      prefix: 'A',
      color: colors[0],
      count: 5,
    );

    final queueB = _createQueue(
      prefix: 'B',
      color: colors[1],
      count: 5,
    );

    return Level(
      number: levelNumber,
      boardSize: 8,
      buses: buses,
      queueA: queueA,
      queueB: queueB,
    );
  }

  static List<Customer> _createQueue({
    required String prefix,
    required Color color,
    required int count,
  }) {
    return List.generate(
      count,
      (index) => Customer(
        id: '${prefix}_${index + 1}',
        color: color,
        queuePosition: index,
      ),
    );
  }

  static List<Color> _getLevelColors() {
    return const [
      Color(0xFFFF6B6B),
      Color(0xFF4DABF7),
      Color(0xFFFFD43B),
      Color(0xFF69DB7C),
      Color(0xFFCC5DE8),
    ];
  }
}