import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final bgColor = color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case OrderStatus.draft:
        return AppColors.statusDraft;
      case OrderStatus.sent:
        return AppColors.statusSent;
      case OrderStatus.done:
        return AppColors.statusDone;
    }
  }
}
