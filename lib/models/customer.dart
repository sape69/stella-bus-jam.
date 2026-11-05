import 'package:flutter/material.dart';

class Customer {
  final String id;
  final Color color;
  final int queuePosition;

  const Customer({
    required this.id,
    required this.color,
    required this.queuePosition,
  });

  Customer copyWith({
    String? id,
    Color? color,
    int? queuePosition,
  }) {
    return Customer(
      id: id ?? this.id,
      color: color ?? this.color,
      queuePosition: queuePosition ?? this.queuePosition,
    );
  }
}