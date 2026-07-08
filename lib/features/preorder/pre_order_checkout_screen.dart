import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class PreOrderCheckoutScreen extends ConsumerStatefulWidget {
  const PreOrderCheckoutScreen({super.key});

  @override
  ConsumerState<PreOrderCheckoutScreen> createState() =>
      _PreOrderCheckoutScreenState();
}

class _PreOrderCheckoutScreenState extends ConsumerState<PreOrderCheckoutScreen> {
  String _paymentMethod = 'cod';
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Order Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.warningOrange, size: 20),
                      const SizedBox(width: 8),
                      const Text('Pre-Order Information',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Your card will be charged when the item ships\n'
                    '• Estimated ship date: within 30 days\n'
                    '• You can cancel anytime before shipping\n'
                    '• Price is guaranteed at time of order',
                    style:
                        TextStyle(color: AppTheme.warmGray, fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'cod',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                  title: const Text('Pay on Shipment'),
                  subtitle: const Text('Charge when the item is ready'),
                  activeColor: AppTheme.primaryPink,
                ),
                RadioListTile<String>(
                  value: 'card',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                  title: const Text('Credit/Debit Card'),
                  subtitle: const Text('Authorized now, charged later'),
                  activeColor: AppTheme.primaryPink,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (v) =>
                    setState(() => _agreedToTerms = v ?? false),
                activeColor: AppTheme.primaryPink,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _agreedToTerms = !_agreedToTerms),
                  child: const Text(
                    'I agree to the pre-order terms and conditions',
                    style: TextStyle(fontSize: 13, color: AppTheme.warmGray),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _agreedToTerms ? () => _placePreOrder(context) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Place Pre-Order'),
            ),
          ),
        ],
      ),
    );
  }

  void _placePreOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pre-order placed successfully!'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/orders');
  }
}
