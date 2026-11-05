import 'bus.dart';
import 'customer.dart';

class Level {
  final int number;
  final int boardSize;
  final List<Bus> buses;
  final List<Customer> queueA;
  final List<Customer> queueB;

  const Level({
    required this.number,
    required this.boardSize,
    required this.buses,
    required this.queueA,
    required this.queueB,
  });

  int get totalCustomers => queueA.length + queueB.length;

  int get totalBuses => buses.length;

  Level copyWith({
    int? number,
    int? boardSize,
    List<Bus>? buses,
    List<Customer>? queueA,
    List<Customer>? queueB,
  }) {
    return Level(
      number: number ?? this.number,
      boardSize: boardSize ?? this.boardSize,
      buses: buses ?? this.buses,
      queueA: queueA ?? this.queueA,
      queueB: queueB ?? this.queueB,
    );
  }
}