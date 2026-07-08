import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/order.dart';
import '../../core/api/order_service.dart';
import '../../core/utils/api_constants.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/skeletons.dart';

final ordersListProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderServiceProvider).getOrders();
});

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Status filter tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _StatusTab('all', 'All', _statusFilter),
                _StatusTab('pending', 'Pending', _statusFilter),
                _StatusTab('processing', 'Processing', _statusFilter),
                _StatusTab('shipped', 'Shipped', _statusFilter),
                _StatusTab('delivered', 'Delivered', _statusFilter),
                _StatusTab('cancelled', 'Cancelled', _statusFilter),
              ],
            ),
          ),
          // Orders list
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filtered = _statusFilter == 'all'
                    ? orders
                    : orders.where((o) => o.orderStatus.toLowerCase() == _statusFilter).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: _statusFilter == 'all' ? 'No orders yet' : 'No $_statusFilter orders',
                    subtitle: _statusFilter == 'all' ? 'Your orders will appear here' : 'Try a different filter',
                    actionLabel: _statusFilter == 'all' ? 'Start Shopping' : null,
                    onAction: _statusFilter == 'all' ? () => context.go('/products') : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ordersListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _OrderCard(order: filtered[i]),
                  ),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 4,
                itemBuilder: (_, __) => const ListTileSkeleton(),
              ),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline, title: 'Error', subtitle: e.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(ordersListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String value;
  final String label;
  final String current;

  const _StatusTab(this.value, this.label, this.current);

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () {
        final screen = context.findAncestorStateOfType<_OrdersScreenState>();
        screen?.setState(() => screen._statusFilter = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryPink : AppTheme.primaryPink.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(color: active ? Colors.white : AppTheme.primaryPink, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${order.trackingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  _StatusBadge(status: order.orderStatus),
                ],
              ),
            ),
            // Items preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  ...order.items.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: item.productImage.isNotEmpty ? ApiConstants.productImageUrl(item.productImage) : '',
                            width: 40, height: 40, fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 40, height: 40,
                              color: AppTheme.secondaryPink.withOpacity(0.2),
                              child: const Icon(Icons.spa, size: 16, color: AppTheme.primaryPink),
                            ),
                          ),
                        ),
                      )),
                  if (order.items.length > 3)
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppTheme.warmGray.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text('+${order.items.length - 3}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.warmGray)),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${order.itemCount} items', style: const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                      const SizedBox(height: 2),
                      Text(order.createdAt, style: const TextStyle(fontSize: 10, color: AppTheme.warmGray)),
                    ],
                  ),
                  Text('\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.accentRose)),
                ],
              ),
            ),
            // Cancel button
            if (order.orderStatus == 'pending')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _cancelOrder(context, order),
                  child: const Text('Cancel Order', style: TextStyle(color: AppTheme.errorRed, fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _cancelOrder(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: Text('Are you sure you want to cancel order #${order.trackingId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order cancellation requested'), backgroundColor: AppTheme.warningOrange),
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Color _statusColor(String s) {
    return switch (s.toLowerCase()) {
      'pending' => AppTheme.warningOrange,
      'processing' || 'confirmed' => AppTheme.primaryPink,
      'shipped' => AppTheme.softGreen,
      'delivered' => AppTheme.successGreen,
      'cancelled' || 'returned' => AppTheme.errorRed,
      _ => AppTheme.warmGray,
    };
  }
}
