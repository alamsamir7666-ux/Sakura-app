import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/address.dart';
import '../../core/models/cart.dart';
import '../../core/api/cart_service.dart';
import '../../core/api/order_service.dart';
import '../../core/api/user_service.dart';
import '../../core/api/extra_services.dart';
import '../../core/providers/app_providers.dart';

final addressesProvider = FutureProvider<List<Address>>((ref) {
  return ref.watch(userServiceProvider).getAddresses();
});

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _paymentMethod = 'cod';
  String? _selectedAddressId;
  final _couponController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartDetailProvider);
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartAsync.when(
        data: (cart) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Shipping Address
              const Text('Shipping Address',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              addressesAsync.when(
                data: (addresses) {
                  if (addresses.isEmpty) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.add_location),
                        title: const Text('Add a shipping address'),
                        trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.push('/addresses'),
                      ),
                    );
                  }
                  return Column(
                    children: addresses.map((addr) {
                      final isSelected = _selectedAddressId ==
                          addr.id.toString();
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryPink
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: addr.id.toString(),
                          groupValue: _selectedAddressId,
                          onChanged: (v) =>
                              setState(() => _selectedAddressId = v),
                          title: Text(addr.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${addr.fullAddress}\n${addr.phone}'),
                          activeColor: AppTheme.primaryPink,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              // Payment Method
              const Text('Payment Method',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'cod',
                      groupValue: _paymentMethod,
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v!),
                      title: const Text('Cash on Delivery'),
                      subtitle:
                          const Text('Pay when you receive'),
                      activeColor: AppTheme.primaryPink,
                    ),
                    RadioListTile<String>(
                      value: 'bkash',
                      groupValue: _paymentMethod,
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v!),
                      title: const Text('bKash'),
                      subtitle:
                          const Text('Pay with bKash mobile'),
                      activeColor: AppTheme.primaryPink,
                    ),
                    RadioListTile<String>(
                      value: 'card',
                      groupValue: _paymentMethod,
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v!),
                      title: const Text('Credit/Debit Card'),
                      subtitle: const Text(
                          'Visa, Mastercard, Amex'),
                      activeColor: AppTheme.primaryPink,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Coupon
              const Text('Coupon Code',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: const InputDecoration(
                        hintText: 'Enter coupon code',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Apply'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Order Summary
              const Text('Order Summary',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SummaryRow(
                          'Subtotal',
                          '\$${cart.subtotal.toStringAsFixed(2)}'),
                      if (cart.discount > 0)
                        _SummaryRow(
                            'Discount',
                            '-\$${cart.discount.toStringAsFixed(2)}',
                            color: AppTheme.successGreen),
                      _SummaryRow('Shipping', 'Free',
                          color: AppTheme.successGreen),
                      const Divider(),
                      _SummaryRow(
                        'Total',
                        '\$${cart.total.toStringAsFixed(2)}',
                        isBold: true,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _placeOrder(context, ref, cart),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Place Order - \$${cart.total.toStringAsFixed(2)}'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        loading: () => const Center(
            child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _placeOrder(
      BuildContext context, WidgetRef ref, Cart cart) async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final addresses = await ref.read(userServiceProvider).getAddresses();
      final address =
          addresses.firstWhere((a) => a.id.toString() == _selectedAddressId);

      final order = await ref.read(orderServiceProvider).createOrder(
            paymentMethod: _paymentMethod,
            shippingAddress: AddressBody(
              fullName: address.fullName,
              phone: address.phone,
              street: address.street,
              city: address.city,
              district: address.district,
              postalCode: address.postalCode,
            ),
            couponCode: _couponController.text.isNotEmpty
                ? _couponController.text
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.trackingId} placed successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        ref.invalidate(cartDetailProvider);
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;
  final double fontSize;

  const _SummaryRow(this.label, this.value,
      {this.color, this.isBold = false, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: color ?? AppTheme.warmGray,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
              )),
          Text(value,
              style: TextStyle(
                color: color ?? AppTheme.charcoal,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: fontSize,
              )),
        ],
      ),
    );
  }
}
