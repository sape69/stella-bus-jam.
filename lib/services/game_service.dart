
import '../models/bus.dart';
import '../models/customer.dart';

class GameService {
  GameService._();

  static const int parkingSlots = 3;

  /// Tarkistaa, onko bussissa vielä tilaa.
  static bool canBoard(Bus bus) {
    return bus.passengers < bus.capacity;
  }

  /// Tarkistaa, onko bussi täynnä.
  static bool isBusFull(Bus bus) {
    return bus.passengers >= bus.capacity;
  }

  /// Laskee, kuinka monta matkustajaa voidaan ottaa jonosta.
  ///
  /// Vain jonon ensimmäiset matkustajat huomioidaan.
  /// Jonossa ei ohiteta erivärisiä matkustajia.
  static int countMatchingPassengers({
    required Bus bus,
    required List<Customer> queue,
  }) {
    final availableSeats = bus.capacity - bus.passengers;

    if (availableSeats <= 0 || queue.isEmpty) {
      return 0;
    }

    var count = 0;

    for (final customer in queue) {
      if (customer.color != bus.color) {
        break;
      }

      count++;

      if (count >= availableSeats) {
        break;
      }
    }

    return count;
  }

  /// Tarkistaa, pääseekö bussi poistumaan pelilaudalta.
  ///
  /// Muut laudalla olevat bussit estävät poistumisen,
  /// jos ne ovat bussin poistumisreitillä.
  static bool canBusExit({
    required Bus bus,
    required List<Bus> otherBuses,
    required int boardSize,
  }) {
    final occupiedCells = <String>{};

    for (final otherBus in otherBuses) {
      if (otherBus.id == bus.id) {
        continue;
      }

      for (var i = 0; i < otherBus.length; i++) {
        final row = otherBus.direction == BusDirection.vertical
            ? otherBus.row + i
            : otherBus.row;

        final column = otherBus.direction == BusDirection.horizontal
            ? otherBus.column + i
            : otherBus.column;

        occupiedCells.add('$row,$column');
      }
    }

    switch (bus.exitDirection) {
      case BusExitDirection.right:
        for (var column = bus.column + bus.length;
            column < boardSize;
            column++) {
          if (occupiedCells.contains('${bus.row},$column')) {
            return false;
          }
        }
        break;

      case BusExitDirection.left:
        for (var column = bus.column - 1;
            column >= 0;
            column--) {
          if (occupiedCells.contains('${bus.row},$column')) {
            return false;
          }
        }
        break;

      case BusExitDirection.down:
        for (var row = bus.row + bus.length;
            row < boardSize;
            row++) {
          if (occupiedCells.contains('$row,${bus.column}')) {
            return false;
          }
        }
        break;

      case BusExitDirection.up:
        for (var row = bus.row - 1;
            row >= 0;
            row--) {
          if (occupiedCells.contains('$row,${bus.column}')) {
            return false;
          }
        }
        break;
    }

    return true;
  }

  /// Tarkistaa, onko pysäköinnissä vapaa paikka.
  static int findFreeParkingSlot(List<Bus?> parkingSlots) {
    return parkingSlots.indexWhere((bus) => bus == null);
  }

  /// Lisää bussin ensimmäiseen vapaaseen pysäköintipaikkaan.
  ///
  /// Palauttaa päivitetyn pysäköintilistan.
  /// Jos paikkoja ei ole, palauttaa null.
  static List<Bus?>? parkBus({
    required List<Bus?> parkingSlots,
    required Bus bus,
  }) {
    final updatedParking = List<Bus?>.from(parkingSlots);
    final freeSlot = findFreeParkingSlot(updatedParking);

    if (freeSlot == -1) {
      return null;
    }

    updatedParking[freeSlot] = bus;

    return updatedParking;
  }

  /// Luo matkustajien nousujärjestyksen muuttamatta pelitilaa.
  ///
  /// Jokainen BoardingAction kuvaa yhtä matkustajaa,
  /// joka nousee tiettyyn pysäköityyn bussiin.
  ///
  /// Jonon A ensimmäinen matkustaja on etusijalla.
  /// Jos A:n ensimmäinen matkustaja ei sovi bussiin,
  /// tarkistetaan jonon B ensimmäinen matkustaja.
  ///
  /// Jonossa ei koskaan ohiteta ensimmäistä matkustajaa.
  ///
  /// Tämä suunnitelma mahdollistaa matkustajien
  /// yksittäisen animaation GamePage-luokassa.
  static List<BoardingAction> createBoardingPlan({
    required List<Bus?> parkingSlots,
    required List<Customer> queueA,
    required List<Customer> queueB,
  }) {
    final parking = List<Bus?>.from(parkingSlots);
    final remainingA = List<Customer>.from(queueA);
    final remainingB = List<Customer>.from(queueB);

    final actions = <BoardingAction>[];

    var changed = true;

    while (changed) {
      changed = false;

      for (var i = 0; i < parking.length; i++) {
        final parkedBus = parking[i];

        if (parkedBus == null) {
          continue;
        }

        var bus = parkedBus;

        while (!bus.isFull) {
          Customer? nextCustomer;
          BoardingQueue? sourceQueue;

          if (remainingA.isNotEmpty &&
              remainingA.first.color == bus.color) {
            nextCustomer = remainingA.removeAt(0);
            sourceQueue = BoardingQueue.a;
          } else if (remainingB.isNotEmpty &&
              remainingB.first.color == bus.color) {
            nextCustomer = remainingB.removeAt(0);
            sourceQueue = BoardingQueue.b;
          }

          if (nextCustomer == null || sourceQueue == null) {
            break;
          }

          actions.add(
            BoardingAction(
              parkingSlotIndex: i,
              customer: nextCustomer,
              queue: sourceQueue,
            ),
          );

          bus = bus.copyWith(
            passengers: bus.passengers + 1,
          );

          changed = true;
        }

        if (bus.isFull) {
          parking[i] = null;
          changed = true;
        } else {
          parking[i] = bus;
        }
      }
    }

    return actions;
  }

  /// Käsittelee pysäköityjen bussien matkustajat.
  ///
  /// Säilyttää aiemman välittömän nousutoiminnon.
  /// Uusi animaatio voidaan toteuttaa käyttämällä
  /// createBoardingPlan-metodia.
  static GameServiceResult processBoarding({
    required List<Bus?> parkingSlots,
    required List<Customer> queueA,
    required List<Customer> queueB,
  }) {
    final parking = List<Bus?>.from(parkingSlots);
    final remainingA = List<Customer>.from(queueA);
    final remainingB = List<Customer>.from(queueB);

    var changed = true;

    while (changed) {
      changed = false;

      for (var i = 0; i < parking.length; i++) {
        final parkedBus = parking[i];

        if (parkedBus == null) {
          continue;
        }

        var bus = parkedBus;

        while (!bus.isFull) {
          Customer? nextCustomer;

          if (remainingA.isNotEmpty &&
              remainingA.first.color == bus.color) {
            nextCustomer = remainingA.removeAt(0);
          } else if (remainingB.isNotEmpty &&
              remainingB.first.color == bus.color) {
            nextCustomer = remainingB.removeAt(0);
          }

          if (nextCustomer == null) {
            break;
          }

          bus = bus.copyWith(
            passengers: bus.passengers + 1,
          );

          changed = true;
        }

        if (bus.isFull) {
          parking[i] = null;
          changed = true;
        } else {
          parking[i] = bus;
        }
      }
    }

    return GameServiceResult(
      parkingSlots: parking,
      queueA: remainingA,
      queueB: remainingB,
    );
  }

  /// Tarkistaa, onko taso valmis.
  static bool isLevelComplete({
    required List<Bus> remainingBuses,
    required List<Bus?> parkingSlots,
    required List<Customer> queueA,
    required List<Customer> queueB,
  }) {
    return remainingBuses.isEmpty &&
        parkingSlots.every((bus) => bus == null) &&
        queueA.isEmpty &&
        queueB.isEmpty;
  }
}

/// Matkustajan nousussa käytettävä jonon tunniste.
enum BoardingQueue {
  a,
  b,
}

/// Yksittäinen matkustajan nousutapahtuma.
class BoardingAction {
  final int parkingSlotIndex;
  final Customer customer;
  final BoardingQueue queue;

  const BoardingAction({
    required this.parkingSlotIndex,
    required this.customer,
    required this.queue,
  });
}

/// Pelitilan tulos matkustajien käsittelyn jälkeen.
class GameServiceResult {
  final List<Bus?> parkingSlots;
  final List<Customer> queueA;
  final List<Customer> queueB;

  const GameServiceResult({
    required this.parkingSlots,
    required this.queueA,
    required this.queueB,
  });
}
