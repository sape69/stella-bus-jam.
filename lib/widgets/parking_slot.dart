import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/bus.dart';

class ParkingSlot extends StatelessWidget {
  final int slotNumber;
  final Bus? bus;
  final bool isUnlocked;
  final VoidCallback? onUnlock;

  const ParkingSlot({
    super.key,
    required this.slotNumber,
    this.bus,
    this.isUnlocked = true,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 92,
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.parkingEmpty
            : AppColors.parkingLocked,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? AppColors.purple
              : AppColors.boardBorder,
          width: 1.5,
        ),
      ),
      child: isUnlocked
          ? _buildUnlockedSlot()
          : _buildLockedSlot(),
    );
  }

  Widget _buildUnlockedSlot() {
    if (bus != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_rounded,
            color: bus!.color,
            size: 38,
          ),
          const SizedBox(height: 4),
          Text(
            '${bus!.passengers}/${bus!.capacity}',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_circle_outline,
          color: AppColors.purple,
          size: 27,
        ),
        const SizedBox(height: 5),
        Text(
          'SLOT $slotNumber',
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedSlot() {
    return InkWell(
      onTap: onUnlock,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppColors.gold,
            size: 23,
          ),
          const SizedBox(height: 5),
          const Text(
            'UNLOCK',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'SLOT $slotNumber + AD',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}