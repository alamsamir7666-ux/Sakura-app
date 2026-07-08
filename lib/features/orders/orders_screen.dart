import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/order.dart';
import '../../core/api/order_service.dart';
import '../../shared/widgets/common_widgets.dart';

final ordersListProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderServiceProvider).getOrders();
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined),
            tooltip: 'Track Order',
            onPressed: () => context.push('/track'),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Your orders will appear here',
              actionLabel: 'Start Shopping',
              onAction: () => context.go('/products'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ordersListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load orders',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(ordersListProvider),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _statusColor(String status) {
    return switch (status) {
      'pending' => AppTheme.warningOrange,
      'processing' => AppTheme.primaryPink,
      'shipped' => AppTheme.softGreen,
      'delivered' => AppTheme.successGreen,
      'cancelled' => AppTheme.errorRed,
      _ => AppTheme.warmGray,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.trackingId}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.orderStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.orderStatus.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(order.orderStatus),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${order.itemCount} items • ${order.createdAt}',
                style: const TextStyle(
                    color: AppTheme.warmGray, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment, size: 14, color: AppTheme.warmGray),
                    const SizedBox(width: 4),
                    Text(order.paymentMethod.toUpperCase(),
                        style:
                            const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: order.paymentStatus == 'paid'
                            ? AppTheme.successGreen.withOpacity(0.1)
                            : AppTheme.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(order.paymentStatus,
                          style: TextStyle(
                            fontSize: 10,
                            color: order.paymentStatus == 'paid'
                                ? AppTheme.successGreen
                                : AppTheme.warningOrange,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
                Text('\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
