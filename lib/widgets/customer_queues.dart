import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/customer.dart';

class CustomerQueues extends StatelessWidget {
  final List<Customer> queueA;
  final List<Customer> queueB;

  const CustomerQueues({
    super.key,
    required this.queueA,
    required this.queueB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
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
          const Text(
            'PASSENGER QUEUES',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildQueueRow('A', queueA),
          const SizedBox(height: 10),
          _buildQueueRow('B', queueB),
        ],
      ),
    );
  }

  Widget _buildQueueRow(
    String label,
    List<Customer> customers,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: customers.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 6),
              itemBuilder: (context, index) {
                return _buildCustomer(customers[index]);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${customers.length}',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomer(Customer customer) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: customer.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryText.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: customer.color.withValues(alpha: 0.25),
            blurRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 19,
      ),
    );
  }
}