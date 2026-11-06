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
    final bool occupied = bus != null;

    return Container(
      width: 100,
      height: 92,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUnlocked
              ? [
                  const Color(0xFF38244F),
                  const Color(0xFF28183D),
                ]
              : [
                  const Color(0xFF30243A),
                  const Color(0xFF21182D),
                ],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isUnlocked
              ? occupied
                  ? bus!.color.withValues(alpha: 0.85)
                  : AppColors.purple.withValues(alpha: 0.85)
              : AppColors.boardBorder,
          width: occupied ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? occupied
                    ? bus!.color.withValues(alpha: 0.18)
                    : AppColors.purple.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: bus!.color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(
                color: bus!.color.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              color: bus!.color,
              size: 29,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${bus!.passengers}/${bus!.capacity}',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.purple,
            size: 25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'SLOT $slotNumber',
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedSlot() {
    return InkWell(
      onTap: onUnlock,
      borderRadius: BorderRadius.circular(17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_rounded,
            color: AppColors.gold,
            size: 25,
          ),
          const SizedBox(height: 5),
          const Text(
            'UNLOCK',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
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