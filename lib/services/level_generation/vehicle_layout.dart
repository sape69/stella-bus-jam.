
import 'package:flutter/material.dart';

import '../../../models/bus.dart';

class VehicleLayout {
  final int x;
  final int y;
  final BusExitDirection direction;
  final int length;

  const VehicleLayout({
    required this.x,
    required this.y,
    required this.direction,
    required this.length,
  });

  int get row => y;

  int get column => x;

  BusDirection get busDirection {
    switch (direction) {
      case BusExitDirection.left:
      case BusExitDirection.right:
        return BusDirection.horizontal;

      case BusExitDirection.up:
      case BusExitDirection.down:
        return BusDirection.vertical;
    }
  }

  Bus toBus({
    required String id,
    required Color color,
    required int capacity,
  }) {
    return Bus(
      id: id,
      color: color,
      capacity: capacity,
      direction: busDirection,
      exitDirection: direction,
      row: row,
      column: column,
      length: length,
    );
  }
}

class BoardCell {
  final int x;
  final int y;

  const BoardCell(this.x, this.y);

  @override
  bool operator ==(Object other) {
    return other is BoardCell && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

class VehicleBoardLayout {
  final int boardSize;
  final List<VehicleLayout> vehicles;
  final List<int> exitOrder;

  const VehicleBoardLayout({
    required this.boardSize,
    required this.vehicles,
    required this.exitOrder,
  });
}
