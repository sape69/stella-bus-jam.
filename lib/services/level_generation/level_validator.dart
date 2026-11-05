
import '../../models/bus.dart';
import '../../models/customer.dart';
import 'vehicle_layout.dart';

class LevelValidator {
  LevelValidator._();

  static const int parkingSlots = 3;

  static bool validate({
    required VehicleBoardLayout layout,
    required List<Bus> buses,
    required List<Customer> queueA,
    required List<Customer> queueB,
  }) {
    if (buses.length != layout.vehicles.length ||
        layout.exitOrder.length != buses.length) {
      return false;
    }

    final remaining = List<int>.generate(
      buses.length,
      (index) => index,
    );

    final parking = List<Bus?>.filled(parkingSlots, null);
    final customersA = List<Customer>.from(queueA);
    final customersB = List<Customer>.from(queueB);

    for (final busIndex in layout.exitOrder) {
      if (!remaining.contains(busIndex)) return false;

      final vehicle = layout.vehicles[busIndex];

      final otherVehicles = remaining
          .where((index) => index != busIndex)
          .map((index) => layout.vehicles[index])
          .toList();

      if (!_hasClearExit(
        vehicle,
        otherVehicles,
        layout.boardSize,
      )) {
        return false;
      }

      final freeSlot = parking.indexWhere(
        (bus) => bus == null,
      );

      if (freeSlot == -1) return false;

      parking[freeSlot] = buses[busIndex];
      remaining.remove(busIndex);

      _processBoarding(
        parking,
        customersA,
        customersB,
      );
    }

    return remaining.isEmpty &&
        parking.every((bus) => bus == null) &&
        customersA.isEmpty &&
        customersB.isEmpty;
  }

  static void _processBoarding(
    List<Bus?> parking,
    List<Customer> queueA,
    List<Customer> queueB,
  ) {
    for (var i = 0; i < parking.length; i++) {
      var bus = parking[i];

      if (bus == null) continue;

      while (!bus.isFull) {
        if (queueA.isNotEmpty &&
            queueA.first.color == bus.color) {
          queueA.removeAt(0);
        } else if (queueB.isNotEmpty &&
            queueB.first.color == bus.color) {
          queueB.removeAt(0);
        } else {
          break;
        }

        bus = bus.copyWith(
          passengers: bus.passengers + 1,
        );
      }

      parking[i] = bus.isFull ? null : bus;
    }
  }

  static bool _hasClearExit(
    VehicleLayout vehicle,
    List<VehicleLayout> others,
    int size,
  ) {
    final occupied = <BoardCell>{};

    for (final other in others) {
      occupied.addAll(_cells(other));
    }

    for (final cell in _exitRay(vehicle, size)) {
      if (occupied.contains(cell)) return false;
    }

    return true;
  }

  static List<BoardCell> _cells(
    VehicleLayout vehicle,
  ) {
    return List.generate(vehicle.length, (index) {
      switch (vehicle.direction) {
        case BusExitDirection.left:
        case BusExitDirection.right:
          return BoardCell(vehicle.x + index, vehicle.y);

        case BusExitDirection.up:
        case BusExitDirection.down:
          return BoardCell(vehicle.x, vehicle.y + index);
      }
    });
  }

  static List<BoardCell> _exitRay(
    VehicleLayout vehicle,
    int size,
  ) {
    final cells = <BoardCell>[];

    switch (vehicle.direction) {
      case BusExitDirection.right:
        for (var x = vehicle.x + vehicle.length; x < size; x++) {
          cells.add(BoardCell(x, vehicle.y));
        }
        break;

      case BusExitDirection.left:
        for (var x = vehicle.x - 1; x >= 0; x--) {
          cells.add(BoardCell(x, vehicle.y));
        }
        break;

      case BusExitDirection.down:
        for (var y = vehicle.y + vehicle.length; y < size; y++) {
          cells.add(BoardCell(vehicle.x, y));
        }
        break;

      case BusExitDirection.up:
        for (var y = vehicle.y - 1; y >= 0; y--) {
          cells.add(BoardCell(vehicle.x, y));
        }
        break;
    }

    return cells;
  }
}
