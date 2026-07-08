import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/cart_service.dart';
import '../../core/models/cart.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/api_constants.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/skeletons.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(cartServiceProvider).clearCart();
              ref.invalidate(cartDetailProvider);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add some Japanese skincare products!',
              actionLabel: 'Start Shopping',
              onAction: () => context.go('/products'),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              ref
                                  .read(cartServiceProvider)
                                  .removeFromCart(item.productId);
                              ref.invalidate(cartDetailProvider);
                            },
                            backgroundColor: AppTheme.errorRed,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Remove',
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPink.withOpacity(0.06),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: item.product.images.isNotEmpty
                                    ? ApiConstants.productImageUrl(
                                        item.product.images.first)
                                    : '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  color: AppTheme.secondaryPink
                                      .withOpacity(0.2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '\$${item.product.effectivePrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: AppTheme.accentRose,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppTheme.primaryPink
                                        .withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        size: 16),
                                    onPressed: item.quantity > 1
                                        ? () {
                                            ref
                                                .read(cartServiceProvider)
                                                .updateCartItem(
                                                  item.productId,
                                                  item.quantity - 1,
                                                );
                                            ref
                                                .invalidate(cartDetailProvider);
                                          }
                                        : null,
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Text('${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () {
                                      ref
                                          .read(cartServiceProvider)
                                          .updateCartItem(
                                            item.productId,
                                            item.quantity + 1,
                                          );
                                      ref.invalidate(cartDetailProvider);
                                    },
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Checkout bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal',
                              style: TextStyle(color: AppTheme.warmGray)),
                          Text('\$${cart.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (cart.discount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount',
                                style: TextStyle(
                                    color: AppTheme.successGreen)),
                            Text(
                                '-\$${cart.discount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: AppTheme.successGreen)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text('\$${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppTheme.accentRose)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/checkout'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                              'Checkout (${cart.itemCount} items)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Column(
          children: List.generate(
              4,
              (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: ListTileSkeleton(),
                  )),
        ),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load cart',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(cartDetailProvider),
        ),
      ),
    );
  }
}
