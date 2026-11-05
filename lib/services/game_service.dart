import '../models/bus.dart';
import '../models/customer.dart';

class GameService {
  GameService._();

  /// Laskee, kuinka monta samanväristä matkustajaa
  /// jonossa on mahdollista ottaa bussiin.
  static int countMatchingPassengers({
    required Bus bus,
    required List<Customer> queue,
  }) {
    final availableSeats = bus.capacity - bus.passengers;

    if (availableSeats <= 0) {
      return 0;
    }

    var matchingCount = 0;

    for (final customer in queue) {
      if (customer.color != bus.color) {
        continue;
      }

      matchingCount++;

      if (matchingCount >= availableSeats) {
        break;
      }
    }

    return matchingCount;
  }

  /// Tarkistaa, onko bussissa vielä tilaa.
  static bool canBoard(Bus bus) {
    return bus.passengers < bus.capacity;
  }

  /// Tarkistaa, onko bussi täynnä.
  static bool isBusFull(Bus bus) {
    return bus.passengers >= bus.capacity;
  }
}