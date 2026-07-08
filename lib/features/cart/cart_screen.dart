import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/cart_service.dart';
import '../../core/models/cart.dart';
import '../../core/utils/api_constants.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/skeletons.dart';
import '../../core/providers/app_providers.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponController = TextEditingController();
  String? _appliedCoupon;
  bool _applyingCoupon = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(cartServiceProvider).clearCart();
              ref.invalidate(cartDetailProvider);
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined, title: 'Your cart is empty',
              subtitle: 'Discover premium Japanese skincare!', actionLabel: 'Start Shopping',
              onAction: () => context.go('/products'),
            );
          }
          return Column(
            children: [
              Expanded(child: _buildCartItems(cart)),
              _buildCouponSection(cart),
              _buildCheckoutBar(cart),
            ],
          );
        },
        loading: () => Column(
          children: List.generate(4, (_) => const Padding(padding: EdgeInsets.all(16), child: ListTileSkeleton())),
        ),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline, title: 'Could not load cart', subtitle: e.toString(),
          actionLabel: 'Retry', onAction: () => ref.invalidate(cartDetailProvider),
        ),
      ),
    );
  }

  Widget _buildCartItems(Cart cart) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(cartDetailProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: cart.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = cart.items[i];
          return Slidable(
            endActionPane: ActionPane(motion: const ScrollMotion(), children: [
              SlidableAction(
                onPressed: (_) async {
                  await ref.read(cartServiceProvider).removeFromCart(item.productId);
                  ref.invalidate(cartDetailProvider);
                },
                backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white,
                icon: Icons.delete, label: 'Remove',
              ),
            ]),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  // Image
                  GestureDetector(
                    onTap: () => context.push('/products/${item.product.id}'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: item.product.images.isNotEmpty ? ApiConstants.productImageUrl(item.product.images.first) : '',
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 80, height: 80, color: AppTheme.secondaryPink.withOpacity(0.15),
                          child: const Icon(Icons.spa, color: AppTheme.primaryPink, size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 3),
                        Text(item.product.category, style: const TextStyle(fontSize: 10, color: AppTheme.primaryPink)),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${item.product.effectivePrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.accentRose)),
                            if (item.product.hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text('\$${item.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.warmGray, decoration: TextDecoration.lineThrough)),
                            ],
                            const Spacer(),
                            Text('\$${item.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.charcoal)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Quantity
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await ref.read(cartServiceProvider).updateCartItem(item.productId, item.quantity + 1);
                            ref.invalidate(cartDetailProvider);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Icon(Icons.add, size: 14, color: AppTheme.primaryPink),
                          ),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        InkWell(
                          onTap: item.quantity > 1 ? () async {
                            await ref.read(cartServiceProvider).updateCartItem(item.productId, item.quantity - 1);
                            ref.invalidate(cartDetailProvider);
                          } : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Icon(Icons.remove, size: 14,
                                color: item.quantity > 1 ? AppTheme.primaryPink : AppTheme.warmGray.withOpacity(0.3)),
                          ),
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
    );
  }

  Widget _buildCouponSection(Cart cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.discount, color: AppTheme.mutedGold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: InputDecoration(
                hintText: 'Coupon code',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              enabled: _appliedCoupon == null,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: _appliedCoupon != null
                ? OutlinedButton(
                    onPressed: () {
                      setState(() { _appliedCoupon = null; _couponController.clear(); });
                    },
                    child: const Text('Remove', style: TextStyle(fontSize: 12)),
                  )
                : ElevatedButton(
                    onPressed: _applyingCoupon ? null : () {
                      if (_couponController.text.trim().isNotEmpty) {
                        setState(() { _appliedCoupon = _couponController.text.trim(); });
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                    child: Text(_applyingCoupon ? '...' : 'Apply', style: const TextStyle(fontSize: 12)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(Cart cart) {
    final discount = _appliedCoupon != null ? cart.subtotal * 0.1 : 0.0;
    final total = cart.subtotal - discount;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 14, bottom: MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: AppTheme.warmGray, fontSize: 13)),
                Text('\$${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            if (discount > 0) ...[
              const SizedBox(height: 2),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.discount, size: 12, color: AppTheme.successGreen),
                    const SizedBox(width: 4),
                    const Text('Discount', style: TextStyle(color: AppTheme.successGreen, fontSize: 13)),
                  ]),
                  Text('-\$${discount.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.accentRose)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.accentRose,
                ),
                child: Text('Checkout (${cart.itemCount} items)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
