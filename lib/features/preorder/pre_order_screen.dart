import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class PreOrderScreen extends StatelessWidget {
  const PreOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Orders')),
      body: const EmptyState(
        icon: Icons.shopping_cart_checkout,
        title: 'No pre-orders available',
        subtitle: 'Check back for upcoming product launches',
      ),
    );
  }
}
