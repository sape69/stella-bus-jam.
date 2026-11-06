
import '../models/bus.dart';
import '../models/customer.dart';
import 'game_service.dart';

/// Hoitaa pysäköityjen bussien matkustajien nousujärjestyksen.
class PassengerBoardingService {
  PassengerBoardingService._();

  /// Käsittelee matkustajien nousut yksi kerrallaan.
  ///
  /// Animaatio ja käyttöliittymän päivitys annetaan
  /// GamePage-luokasta callback-funktioina.
  static Future<void> processBoarding({
    required List<Bus?> parkingSlots,
    required List<Customer> queueA,
    required List<Customer> queueB,
    required bool Function() isMounted,
    required Future<void> Function(BoardingAction action)
        animatePassenger,
    required void Function(BoardingAction action) onPassengerBoarded,
  }) async {
    final actions = GameService.createBoardingPlan(
      parkingSlots: parkingSlots,
      queueA: queueA,
      queueB: queueB,
    );

    for (final action in actions) {
      if (!isMounted()) {
        return;
      }

      final slotIndex = action.parkingSlotIndex;

      if (slotIndex < 0 || slotIndex >= parkingSlots.length) {
        continue;
      }

      final bus = parkingSlots[slotIndex];

      if (bus == null || bus.isFull) {
        continue;
      }

      final queue = action.queue == BoardingQueue.a
          ? queueA
          : queueB;

      if (queue.isEmpty || queue.first.id != action.customer.id) {
        continue;
      }

      await animatePassenger(action);

      if (!isMounted()) {
        return;
      }

      final currentBus = parkingSlots[slotIndex];

      final currentQueue = action.queue == BoardingQueue.a
          ? queueA
          : queueB;

      if (currentBus == null ||
          currentBus.isFull ||
          currentQueue.isEmpty ||
          currentQueue.first.id != action.customer.id) {
        continue;
      }

      onPassengerBoarded(action);

      await Future.delayed(
        const Duration(milliseconds: 120),
      );
    }
  }
}
