import 'package:flutter/material.dart';

enum BusDirection {
  horizontal,
  vertical,
}

class Bus {
  final String id;
  final Color color;
  final int capacity;
  final BusDirection direction;
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
    this.passengers = 0,
  });

  bool get isFull => passengers >= capacity;

  bool get hasSpace => passengers < capacity;

  Bus copyWith({
    String? id,
    Color? color,
    int? capacity,
    BusDirection? direction,
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
      row: row ?? this.row,
      column: column ?? this.column,
      length: length ?? this.length,
      passengers: passengers ?? this.passengers,
    );
  }
}