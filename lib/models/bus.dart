
import 'package:flutter/material.dart';

enum BusDirection {
  horizontal,
  vertical,
}

enum BusExitDirection {
  up,
  down,
  left,
  right,
}

class Bus {
  final String id;
  final Color color;
  final int capacity;
  final BusDirection direction;
  final BusExitDirection exitDirection;
  final int row;
  final int column;
  final int length;
  final int passengers;

  const Bus({
    required this.id,
    required this.color,
    required this.capacity,
    required this.direction,
    required this.row,
    required this.column,
    required this.length,
    this.exitDirection = BusExitDirection.right,
    this.passengers = 0,
  });

  bool get isFull => passengers >= capacity;

  bool get hasSpace => passengers < capacity;

  Bus copyWith({
    String? id,
    Color? color,
    int? capacity,
    BusDirection? direction,
    BusExitDirection? exitDirection,
    int? row,
    int? column,
    int? length,
    int? passengers,
  }) {
    return Bus(
      id: id ?? this.id,
      color: color ?? this.color,
      capacity: capacity ?? this.capacity,
      direction: direction ?? this.direction,
      exitDirection: exitDirection ?? this.exitDirection,
      row: row ?? this.row,
      column: column ?? this.column,
      length: length ?? this.length,
      passengers: passengers ?? this.passengers,
    );
  }
}
