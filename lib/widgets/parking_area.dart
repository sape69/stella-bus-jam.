
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/bus.dart';
import 'parking_slot.dart';

class ParkingArea extends StatelessWidget {
  final List<Bus?> parkingSlots;
  final int unlockedExtraSlots;
  final ValueChanged<int>? onUnlockSlot;

  const ParkingArea({
    super.key,
    this.parkingSlots = const [],
    this.unlockedExtraSlots = 0,
    this.onUnlockSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.boardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final slotNumber = index + 1;

                final isUnlocked =
                    slotNumber <= 3 + unlockedExtraSlots;

                final bus = index < parkingSlots.length
                    ? parkingSlots[index]
                    : null;

                return ParkingSlot(
                  slotNumber: slotNumber,
                  bus: bus,
                  isUnlocked: isUnlocked,
                  onUnlock: isUnlocked
                      ? null
                      : () => onUnlockSlot?.call(slotNumber),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.local_parking_rounded,
          color: AppColors.purple,
          size: 22,
        ),
        const SizedBox(width: 8),
        const Text(
          'BUS PARKING',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Text(
          '${3 + unlockedExtraSlots}/5 SLOTS',
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
