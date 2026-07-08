import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: const EmptyState(
        icon: Icons.subscriptions_outlined,
        title: 'No active subscriptions',
        subtitle:
            'Subscribe to your favorite products and save with recurring deliveries',
      ),
    );
  }
}
