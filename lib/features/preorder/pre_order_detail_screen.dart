import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class PreOrderDetailScreen extends StatelessWidget {
  final int preOrderId;
  const PreOrderDetailScreen({super.key, required this.preOrderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Order Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.inventory, size: 48, color: AppTheme.primaryPink),
                  const SizedBox(height: 12),
                  const Text('Pre-Order #${"PRE-123456"}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('AWAITING STOCK',
                        style: TextStyle(
                            color: AppTheme.warningOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Timeline',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTimelineItem('Order Placed',
                      'Your pre-order has been confirmed', true),
                  _buildTimelineItem('In Production',
                      'Manufacturer is preparing your item', true),
                  _buildTimelineItem('Shipping Soon',
                      'Item will ship within 15-30 days', false),
                  _buildTimelineItem('Delivered',
                      'Estimated delivery after shipping', false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
                side: const BorderSide(color: AppTheme.errorRed),
              ),
              child: const Text('Cancel Pre-Order'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool completed) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: completed
                      ? AppTheme.successGreen
                      : AppTheme.warmGray.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: completed
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              Container(width: 2, height: 30, color: AppTheme.warmGray.withOpacity(0.2)),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: completed
                          ? AppTheme.charcoal
                          : AppTheme.warmGray)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.warmGray)),
            ],
          ),
        ],
      ),
    );
  }
}
