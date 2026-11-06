import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/customer.dart';

class CustomerQueues extends StatefulWidget {
  final List<Customer> queueA;
  final List<Customer> queueB;

  const CustomerQueues({
    super.key,
    required this.queueA,
    required this.queueB,
  });

  @override
  State<CustomerQueues> createState() => _CustomerQueuesState();
}

class _CustomerQueuesState extends State<CustomerQueues>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF211238),
            Color(0xFF190E2D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.05),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.purple,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'PASSENGER QUEUES',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Text(
                '${widget.queueA.length + widget.queueB.length} TOTAL',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQueueRow('A', widget.queueA),
          const SizedBox(height: 12),
          _buildQueueRow('B', widget.queueB),
        ],
      ),
    );
  }

  Widget _buildQueueRow(
    String label,
    List<Customer> customers,
  ) {
    final Color queueColor =
        label == 'A' ? AppColors.purple : AppColors.pink;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                queueColor,
                queueColor.withValues(alpha: 0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: queueColor.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: customers.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 7),
              itemBuilder: (context, index) {
                return _buildCustomer(
                  customers[index],
                  index,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          constraints: const BoxConstraints(
            minWidth: 34,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.20),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${customers.length}',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomer(
    Customer customer,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final phase =
            (_animationController.value * 2 * math.pi) +
                (index * 0.55);

        final verticalOffset = math.sin(phase) * 1.5;

        return Transform.translate(
          offset: Offset(0, verticalOffset),
          child: child,
        );
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: customer.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: customer.color.withValues(alpha: 0.30),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}