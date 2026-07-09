import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/address.dart';
import '../../core/models/cart.dart';
import '../../core/api/cart_service.dart';
import '../../core/api/order_service.dart';
import '../../core/api/user_service.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/common_widgets.dart';

final addressesListProvider = FutureProvider<List<Address>>((ref) {
  return ref.watch(userServiceProvider).getAddresses();
});

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final _pageController = PageController();

  // Address
  String? _selectedAddressId;
  final _addrFormKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _postalCode = TextEditingController();

  // Payment
  String _paymentMethod = 'cod';
  final _cardNumber = TextEditingController();
  final _cardExpiry = TextEditingController();
  final _cardCvv = TextEditingController();
  final _transactionId = TextEditingController();

  // Coupon
  final _couponController = TextEditingController();
  String? _appliedCoupon;
  double _discount = 0;

  bool _isProcessing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _fullName.dispose(); _phone.dispose(); _street.dispose();
    _city.dispose(); _district.dispose(); _postalCode.dispose();
    _cardNumber.dispose(); _cardExpiry.dispose(); _cardCvv.dispose();
    _transactionId.dispose(); _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartDetailProvider);
    final addressesAsync = ref.watch(addressesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return const EmptyState(icon: Icons.shopping_bag_outlined, title: 'Cart is empty', subtitle: '');
          }
          return Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAddressStep(addressesAsync),
                    _buildPaymentStep(cart),
                    _buildReviewStep(cart),
                  ],
                ),
              ),
              _buildBottomButtons(cart),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;
          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 32 : 24, height: active ? 32 : 24,
                decoration: BoxDecoration(
                  color: done ? AppTheme.successGreen : active ? AppTheme.primaryPink : AppTheme.warmGray.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                          color: active ? Colors.white : AppTheme.warmGray)),
                ),
              ),
              if (i < 2) Container(width: 40, height: 2, color: done ? AppTheme.successGreen : AppTheme.warmGray.withOpacity(0.2)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAddressStep(AsyncValue<List<Address>> addressesAsync) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        addressesAsync.when(
          data: (addresses) {
            if (addresses.isEmpty) return _buildAddressForm();
            return Column(
              children: [
                ...addresses.map((addr) {
                  final isSelected = _selectedAddressId == addr.id.toString();
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isSelected ? AppTheme.primaryPink : Colors.transparent, width: 2),
                    ),
                    child: RadioListTile<String>(
                      value: addr.id.toString(),
                      groupValue: _selectedAddressId,
                      onChanged: (v) => setState(() => _selectedAddressId = v),
                      title: Text(addr.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${addr.fullAddress}\n${addr.phone}'),
                      activeColor: AppTheme.primaryPink,
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _selectedAddressId = null),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New Address'),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildAddressForm(),
        ),
        if (_selectedAddressId == null && addressesAsync.valueOrNull?.isNotEmpty != true) _buildAddressForm(),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Form(
      key: _addrFormKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(controller: _fullName, decoration: const InputDecoration(labelText: 'Full Name *'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone *'), keyboardType: TextInputType.phone, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _street, decoration: const InputDecoration(labelText: 'Street Address *'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City *'), validator: (v) => v?.isEmpty == true ? 'Required' : null)),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: _district, decoration: const InputDecoration(labelText: 'District *'), validator: (v) => v?.isEmpty == true ? 'Required' : null)),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(controller: _postalCode, decoration: const InputDecoration(labelText: 'Postal Code')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStep(Cart cart) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'cod', groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
                title: const Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pay when you receive your order'),
                activeColor: AppTheme.primaryPink,
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                value: 'bkash', groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
                title: const Text('bKash', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pay with bKash mobile banking'),
                activeColor: AppTheme.primaryPink,
              ),
              if (_paymentMethod == 'bkash')
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                  child: TextField(
                    controller: _transactionId,
                    decoration: const InputDecoration(labelText: 'bKash Transaction ID', hintText: 'Enter your bKash transaction ID'),
                  ),
                ),
              const Divider(height: 1),
              RadioListTile<String>(
                value: 'card', groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
                title: const Text('Credit/Debit Card', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Visa, Mastercard, Amex'),
                activeColor: AppTheme.primaryPink,
              ),
              if (_paymentMethod == 'card')
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                  child: Column(
                    children: [
                      TextField(controller: _cardNumber, decoration: const InputDecoration(labelText: 'Card Number', hintText: '1234 5678 9012 3456'), keyboardType: TextInputType.number),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _cardExpiry, decoration: const InputDecoration(labelText: 'MM/YY'), keyboardType: TextInputType.datetime, maxLength: 5)),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: _cardCvv, decoration: const InputDecoration(labelText: 'CVV'), keyboardType: TextInputType.number, maxLength: 4, obscureText: true)),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Coupon
        const Text('Coupon Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: 'Enter code',
                  suffixIcon: _appliedCoupon != null
                      ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() { _appliedCoupon = null; _discount = 0; _couponController.clear(); }))
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _appliedCoupon != null ? null : () {
                if (_couponController.text.trim().isNotEmpty) {
                  setState(() { _appliedCoupon = _couponController.text.trim(); _discount = 5.0; });
                }
              },
              child: Text(_appliedCoupon != null ? 'Applied' : 'Apply'),
            ),
          ],
        ),
        if (_appliedCoupon != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: AppTheme.successGreen),
                const SizedBox(width: 4),
                Text('Coupon "$_appliedCoupon" applied! -\$${_discount.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.successGreen, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewStep(Cart cart) {
    final total = cart.subtotal - _discount;
    final address = _selectedAddressId != null ? _selectedAddressId : _buildNewAddress();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Order Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shipping To', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(_selectedAddressId != null ? 'Saved Address' : '${_fullName.text}\n${_street.text}\n${_city.text}, ${_district.text}\n${_phone.text}',
                    style: const TextStyle(color: AppTheme.warmGray, fontSize: 13)),
                const SizedBox(height: 12),
                const Text('Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text({ 'cod': 'Cash on Delivery', 'bkash': 'bKash', 'card': 'Credit/Debit Card' }[_paymentMethod]!,
                    style: const TextStyle(color: AppTheme.warmGray, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Items', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...cart.items.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: AppTheme.secondaryPink.withOpacity(0.2),
                    child: const Icon(Icons.spa, color: AppTheme.primaryPink, size: 16)),
                title: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Qty: ${item.quantity} × \$${item.product.effectivePrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                trailing: Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
                if (_discount > 0) _summaryRow('Discount', '-\$${_discount.toStringAsFixed(2)}', color: AppTheme.successGreen),
                _summaryRow('Shipping', 'Free', color: AppTheme.successGreen),
                const Divider(),
                _summaryRow('Total', '\$${total.toStringAsFixed(2)}', isBold: true, fontSize: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  String _buildNewAddress() {
    return '${_fullName.text}\n${_street.text}\n${_city.text}, ${_district.text}';
  }

  Widget _buildBottomButtons(Cart cart) {
    final total = cart.subtotal - _discount;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () => setState(() { _currentStep--; _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              child: const Text('Back'),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () {
                if (_currentStep < 2) {
                  setState(() { _currentStep++; _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); });
                } else {
                  _placeOrder(cart);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _currentStep == 2 ? AppTheme.accentRose : AppTheme.primaryPink,
              ),
              child: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_currentStep == 2 ? 'Place Order • \$${total.toStringAsFixed(2)}' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(Cart cart) async {
    setState(() => _isProcessing = true);

    try {
      AddressBody shippingAddress;
      if (_selectedAddressId != null) {
        final addresses = await ref.read(userServiceProvider).getAddresses();
        final addr = addresses.firstWhere((a) => a.id.toString() == _selectedAddressId);
        shippingAddress = AddressBody(fullName: addr.fullName, phone: addr.phone, street: addr.street, city: addr.city, district: addr.district, postalCode: addr.postalCode);
      } else {
        shippingAddress = AddressBody(fullName: _fullName.text, phone: _phone.text, street: _street.text, city: _city.text, district: _district.text, postalCode: _postalCode.text.isNotEmpty ? _postalCode.text : null);
      }

      final order = await ref.read(orderServiceProvider).createOrder(
        paymentMethod: _paymentMethod,
        transactionId: _transactionId.text.isNotEmpty ? _transactionId.text : null,
        shippingAddress: shippingAddress,
        couponCode: _appliedCoupon,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #${order.trackingId} placed! 🎉'), backgroundColor: AppTheme.successGreen, behavior: SnackBarBehavior.floating),
        );
        ref.invalidate(cartDetailProvider);
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _summaryRow(String label, String value, {Color? color, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color ?? AppTheme.warmGray, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
          Text(value, style: TextStyle(color: color ?? AppTheme.charcoal, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: fontSize)),
        ],
      ),
    );
  }
}
