import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/models/user.dart';
import '../../core/api/product_service.dart';
import '../../core/api/extra_services.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/api_constants.dart';
import '../../shared/widgets/skeletons.dart';
import '../../shared/widgets/common_widgets.dart';

final productDetailProvider =
    FutureProvider.family<Product, int>((ref, id) {
  return ref.watch(productServiceProvider).getProduct(id);
});

final productReviewsProvider =
    FutureProvider.family<List<Review>, int>((ref, productId) {
  return ref.watch(reviewServiceProvider).getReviews(productId);
});

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) => _ProductDetailContent(product: product),
        loading: () => const _ProductDetailSkeleton(),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.error_outline,
            title: 'Product not found',
            subtitle: e.toString(),
            actionLabel: 'Go Back',
            onAction: () => context.pop(),
          ),
        ),
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerStatefulWidget {
  final Product product;

  const _ProductDetailContent({required this.product});

  @override
  ConsumerState<_ProductDetailContent> createState() =>
      _ProductDetailContentState();
}

class _ProductDetailContentState
    extends ConsumerState<_ProductDetailContent> {
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));
    final wishlist = ref.watch(wishlistProvider);

    return CustomScrollView(
      slivers: [
        // Image carousel
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: AppTheme.charcoal),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                if (product.images.isNotEmpty)
                  CarouselSlider(
                    items: product.images.map((img) {
                      return CachedNetworkImage(
                        imageUrl: ApiConstants.productImageUrl(img),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.secondaryPink.withOpacity(0.2),
                          child: const Icon(Icons.spa,
                              color: AppTheme.primaryPink, size: 50),
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 400,
                      viewportFraction: 1,
                      onPageChanged: (index, _) =>
                          setState(() => _currentImageIndex = index),
                    ),
                  )
                else
                  Container(
                    color: AppTheme.secondaryPink.withOpacity(0.2),
                    child: const Center(
                      child: Icon(Icons.spa,
                          color: AppTheme.primaryPink, size: 50),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      product.images.length,
                      (i) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentImageIndex
                              ? AppTheme.primaryPink
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Name
                Text(product.category,
                    style: const TextStyle(
                        color: AppTheme.primaryPink,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.charcoal)),
                const SizedBox(height: 12),
                // Rating
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: product.averageRating,
                      itemBuilder: (_, __) => const Icon(Icons.star,
                          color: AppTheme.mutedGold),
                      itemCount: 5,
                      itemSize: 18,
                    ),
                    const SizedBox(width: 8),
                    Text('${product.averageRating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                        style: const TextStyle(
                            color: AppTheme.warmGray, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                // Price
                PriceDisplay(
                  price: product.effectivePrice,
                  originalPrice:
                      product.hasDiscount ? product.price : null,
                ),
                const SizedBox(height: 16),
                const Divider(),
                // Description
                const SizedBox(height: 12),
                const Text('Description',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(product.description,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.warmGray,
                        height: 1.6)),
                // Key Benefits
                if (product.keyBenefits.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Key Benefits',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...product.keyBenefits.map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppTheme.successGreen, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(benefit,
                                    style: const TextStyle(
                                        color: AppTheme.charcoal,
                                        fontSize: 14))),
                          ],
                        ),
                      )),
                ],
                // Main Ingredients
                if (product.mainIngredients.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Main Ingredients',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.mainIngredients.map((ing) {
                      return Chip(
                        avatar: Text(ing.icon, style: const TextStyle(fontSize: 16)),
                        label: Text(ing.name),
                        backgroundColor:
                            AppTheme.secondaryPink.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
                // Best For
                if (product.bestFor.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Best For',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.bestFor.map((b) {
                      return Chip(
                        label: Text(b, style: const TextStyle(fontSize: 12)),
                        backgroundColor:
                            AppTheme.softGreen.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
                if (product.texture != null) ...[
                  const SizedBox(height: 20),
                  const Text('Texture',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(product.texture!,
                      style: const TextStyle(
                          color: AppTheme.warmGray, fontSize: 14)),
                ],
                if (product.ingredients != null) ...[
                  const SizedBox(height: 20),
                  const Text('Ingredients',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(product.ingredients!,
                      style: const TextStyle(
                          color: AppTheme.warmGray, fontSize: 14)),
                ],
                const SizedBox(height: 20),
                const Divider(),
                // Reviews section
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reviews',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Write a Review'),
                    ),
                  ],
                ),
                reviewsAsync.when(
                  data: (reviews) {
                    if (reviews.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No reviews yet.',
                            style: TextStyle(color: AppTheme.warmGray)),
                      );
                    }
                    return Column(
                      children: reviews.take(3).map((review) {
                        return _ReviewTile(review: review);
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryPink.withOpacity(0.1),
                child: Text(review.userName[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: review.rating.toDouble(),
                          itemBuilder: (_, __) => const Icon(Icons.star,
                              color: AppTheme.mutedGold),
                          itemCount: 5,
                          itemSize: 12,
                        ),
                        const SizedBox(width: 8),
                        Text(review.createdAt,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.warmGray)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment,
              style:
                  const TextStyle(color: AppTheme.charcoal, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ProductDetailSkeleton extends StatelessWidget {
  const _ProductDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: Colors.grey[200]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(8, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShimmerLoading(
                        child: Container(
                          height: 16,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
