import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/order.dart';
import '../../core/api/order_service.dart';
import '../../shared/widgets/common_widgets.dart';

final orderDetailProvider = FutureProvider.family<Order, int>((ref, id) {
  return ref.watch(orderServiceProvider).getOrder(id);
});

class OrderDetailScreen extends ConsumerWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        data: (order) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tracking ID & Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppTheme.successGreen, size: 48),
                    const SizedBox(height: 12),
                    Text('Tracking ID: ${order.trackingId}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Status: ${order.orderStatus.toUpperCase()}',
                        style: const TextStyle(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Items
            const Text('Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...order.items.map((item) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.secondaryPink.withOpacity(0.2),
                      child: const Icon(Icons.spa,
                          color: AppTheme.primaryPink, size: 18),
                    ),
                    title: Text(item.productName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text(
                        'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
                    trailing: Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
                )),
            const SizedBox(height: 16),
            // Shipping
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Shipping Address',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(order.shippingAddress.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(order.shippingAddress.fullAddress),
                    Text(order.shippingAddress.phone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Payment
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Payment Method', order.paymentMethod.toUpperCase()),
                    _row('Payment Status', order.paymentStatus.toUpperCase()),
                    _row('Transaction ID',
                        order.transactionId ?? 'N/A'),
                    const Divider(),
                    _row('Subtotal',
                        '\$${order.totalAmount.toStringAsFixed(2)}'),
                    if (order.discountAmount > 0)
                      _row('Discount',
                          '-\$${order.discountAmount.toStringAsFixed(2)}'),
                    if (order.couponCode != null)
                      _row('Coupon', order.couponCode!),
                    _row('Total',
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Order Date: ${order.createdAt}',
                style:
                    const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
            if (order.cancellationReason != null)
              Text('Cancellation: ${order.cancellationReason}',
                  style: const TextStyle(
                      color: AppTheme.errorRed, fontSize: 12)),
            const SizedBox(height: 32),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Order not found',
          subtitle: e.toString(),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.warmGray)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}
