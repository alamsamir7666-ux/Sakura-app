import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/models/user.dart';
import '../../core/models/product_extra.dart';
import '../../core/api/product_service.dart';
import '../../core/api/extra_services.dart';
import '../../core/api/remaining_services.dart';
import '../../core/api/cart_service.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/api_constants.dart';
import '../../shared/widgets/skeletons.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/product_card.dart';

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  return ref.watch(productServiceProvider).getProduct(id);
});

final productReviewsProvider = FutureProvider.family<List<Review>, int>((ref, productId) {
  return ref.watch(reviewServiceProvider).getReviews(productId);
});

final productVariantsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, id) { return ref.watch(variantServiceProvider).getVariants(id); });

final productQAProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, id) { return ref.watch(qaServiceProvider).getQuestions(id); });

final reviewEligibilityProvider = FutureProvider.family<ReviewEligibility, int>((ref, id) {
  return ref.watch(reviewServiceProvider).getEligibility(id);
});

class _VariantData {
  final Map<String, dynamic> d;
  const _VariantData(this.d);
  int get id => d['id'] as int;
  bool get inStock => d['inStock'] == true;
  String get name => d['name'] as String;
  String? get color => d['color'] as String?;
  String? get size => d['size'] as String?;
  num? get priceModifier => d['priceModifier'] as num?;
}

class _QAData {
  final Map<String, dynamic> d;
  const _QAData(this.d);
  String get question => d['question'] as String;
  bool get isAnswered => d['isAnswered'] == true;
  String? get answer => d['answer'] as String?;
  String get userName => d['userName'] as String? ?? 'Anonymous';
  String get createdAt => d['createdAt'] as String? ?? '';
}

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  int _quantity = 1;
  int? _selectedVariantId;
  bool _showFullDesc = false;
  late final TabController _tabController;
  final _qaQuestionController = TextEditingController();
  final _stockEmailController = TextEditingController();
  bool _isAskingQuestion = false;
  bool _isSubscribingStock = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qaQuestionController.dispose();
    _stockEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return productAsync.when(
      data: (product) => Scaffold(
        backgroundColor: AppTheme.sakuraWhite,
        body: _buildContent(product),
        bottomNavigationBar: _buildBottomBar(product),
      ),
      loading: () => const _ProductDetailSkeleton(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Error', style: TextStyle(color: AppTheme.errorRed, fontSize: 16)), const SizedBox(height: 8), Text(e.toString(), style: const TextStyle(fontSize: 12, color: AppTheme.warmGray), textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: () => ref.invalidate(productDetailProvider(widget.productId)), child: const Text('Retry'))])),
      ),
    );
  }

  Widget _buildContent(Product product) {
    return CustomScrollView(
      slivers: [
        _buildImageCarousel(product),
        SliverToBoxAdapter(child: _buildProductInfo(product)),
        SliverToBoxAdapter(child: _buildVariantSelector()),
        SliverToBoxAdapter(child: _buildTabBar()),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(product),
                _buildReviewsTab(product),
                _buildQATab(product),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildImageCarousel(Product product) {
    final images = product.images.isNotEmpty ? product.images : [''];

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.charcoal,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {},
          tooltip: 'Share',
        ),
        Consumer(
          builder: (context, ref, _) {
            final wishlist = ref.watch(wishlistProvider);
            final isFav = wishlist.contains(product.id);
            return IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppTheme.errorRed : null),
              onPressed: () => ref.read(wishlistProvider.notifier).toggle(product.id),
              tooltip: 'Wishlist',
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _showImageZoom(images, _currentImageIndex),
              child: CarouselSlider(
                items: images.map((img) {
                  return Hero(
                    tag: 'product_${product.id}_$_currentImageIndex',
                    child: CachedNetworkImage(
                      imageUrl: img.isNotEmpty ? ApiConstants.productImageUrl(img) : '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey[200]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.secondaryPink.withOpacity(0.15),
                        child: const Icon(Icons.spa, color: AppTheme.primaryPink, size: 60),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 1,
                  onPageChanged: (i, _) => setState(() => _currentImageIndex = i),
                  enableInfiniteScroll: false,
                ),
              ),
            ),
            if (product.hasDiscount)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRose,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('-${product.discountPercent}% OFF',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            if (product.images.length > 1)
              Positioned(
                bottom: 16, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(product.images.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _currentImageIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _currentImageIndex
                          ? AppTheme.primaryPink
                          : Colors.white.withOpacity(0.6),
                    ),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(product.category, style: const TextStyle(color: AppTheme.primaryPink, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          // Name
          Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.charcoal, height: 1.2)),
          const SizedBox(height: 10),
          // Rating row
          GestureDetector(
            onTap: () => _tabController.animateTo(1),
            child: Row(
              children: [
                RatingBarIndicator(
                  rating: product.averageRating,
                  itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.mutedGold),
                  itemCount: 5, itemSize: 16,
                ),
                const SizedBox(width: 8),
                Text('${product.averageRating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                    style: const TextStyle(color: AppTheme.primaryPink, fontSize: 13, fontWeight: FontWeight.w500)),
                const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.primaryPink),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${product.effectivePrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
              if (product.hasDiscount) ...[
                const SizedBox(width: 10),
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: AppTheme.warmGray, decoration: TextDecoration.lineThrough)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // Stock status
          Row(
            children: [
              Icon(product.inStock ? Icons.check_circle : Icons.cancel,
                  size: 14, color: product.inStock ? AppTheme.successGreen : AppTheme.errorRed),
              const SizedBox(width: 4),
              Text(product.inStock ? 'In Stock (${product.stock} available)' : 'Out of Stock',
                  style: TextStyle(fontSize: 12, color: product.inStock ? AppTheme.successGreen : AppTheme.errorRed)),
            ],
          ),
          // Stock alert if out of stock
          if (!product.inStock) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stockEmailController,
                    decoration: const InputDecoration(
                      hintText: 'Email for stock alert',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubscribingStock ? null : () => _subscribeStockAlert(product.id),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  child: _isSubscribingStock
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Notify Me'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildVariantSelector() {
    final variantsAsync = ref.watch(productVariantsProvider(widget.productId));

    return variantsAsync.when(
      data: (variants) {
        if (variants.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Variant', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: variants.map((v) => _VariantData(v)).map((v) {
                  final selected = _selectedVariantId == v.id;
                  return GestureDetector(
                    onTap: v.inStock ? () => setState(() => _selectedVariantId = selected ? null : v.id) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryPink.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? AppTheme.primaryPink : AppTheme.warmGray.withOpacity(0.3),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (v.color != null) ...[
                            Container(width: 14, height: 14, decoration: BoxDecoration(color: _parseColor(v.color!), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '${v.name}${v.size != null ? ' • ${v.size}' : ''}${v.priceModifier != null ? ' +\$${v.priceModifier!.toStringAsFixed(2)}' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              color: v.inStock ? AppTheme.charcoal : AppTheme.warmGray,
                              decoration: v.inStock ? null : TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _parseColor(String color) {
    try {
      final hex = color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.warmGray;
    }
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.accentRose,
        unselectedLabelColor: AppTheme.warmGray,
        indicatorColor: AppTheme.accentRose,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Description'),
          Tab(text: 'Reviews'),
          Tab(text: 'Q&A'),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(product.description,
              maxLines: _showFullDesc ? null : 4,
              overflow: _showFullDesc ? null : TextOverflow.fade,
              style: const TextStyle(color: AppTheme.charcoal, fontSize: 14, height: 1.7)),
          if (product.description.length > 200)
            GestureDetector(
              onTap: () => setState(() => _showFullDesc = !_showFullDesc),
              child: Text(_showFullDesc ? 'Show less' : 'Read more',
                  style: const TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.w600)),
            ),
          // Key Benefits
          if (product.keyBenefits.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Key Benefits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...product.keyBenefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 12, color: AppTheme.successGreen),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(b, style: const TextStyle(fontSize: 13, color: AppTheme.charcoal, height: 1.4))),
                    ],
                  ),
                )),
          ],
          // Main Ingredients
          if (product.mainIngredients.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Star Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: product.mainIngredients.map((ing) =>
                  Chip(
                    avatar: Text(ing.icon, style: const TextStyle(fontSize: 16)),
                    label: Text(ing.name, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppTheme.secondaryPink.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  )).toList()),
          ],
          // Best For
          if (product.bestFor.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Best For', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: product.bestFor.map((b) =>
                  Chip(label: Text(b, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppTheme.softGreen.withOpacity(0.15),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact)).toList(),
          ],
          // Texture
          if (product.texture != null && product.texture!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Texture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(product.texture!, style: const TextStyle(color: AppTheme.warmGray, fontSize: 13)),
          ],
          // Full ingredients list
          if (product.ingredients != null && product.ingredients!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('All Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(product.ingredients!, style: const TextStyle(color: AppTheme.warmGray, fontSize: 12, height: 1.6)),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsTab(Product product) {
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));
    final eligibilityAsync = ref.watch(reviewEligibilityProvider(product.id));

    return reviewsAsync.when(
      data: (reviews) {
        return Column(
          children: [
            // Rating summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(product.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                      RatingBarIndicator(
                          rating: product.averageRating, itemCount: 5, itemSize: 14,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.mutedGold)),
                      Text('${reviews.length} reviews', style: const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final star = 5 - i;
                        final count = reviews.where((r) => r.rating == star).length;
                        final ratio = reviews.isEmpty ? 0.0 : count / reviews.length;
                        return Row(
                          children: [
                            Text('$star', style: const TextStyle(fontSize: 11, color: AppTheme.warmGray)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                    value: ratio, minHeight: 6,
                                    backgroundColor: AppTheme.warmGray.withOpacity(0.1),
                                    color: AppTheme.mutedGold),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(width: 24, child: Text('$count', style: const TextStyle(fontSize: 10, color: AppTheme.warmGray))),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            // Write review button
            eligibilityAsync.when(
              data: (elig) => elig.canReview
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OutlinedButton.icon(
                        onPressed: () => _showReviewForm(product.id),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Write a Review'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          foregroundColor: AppTheme.primaryPink,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const Divider(),
            // Review list
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No reviews yet. Be the first!', style: TextStyle(color: AppTheme.warmGray))),
              )
            else
              ...reviews.map((review) => _ReviewCard(review: review)),
          ],
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Failed to load reviews: $e', style: const TextStyle(color: AppTheme.errorRed))),
    );
  }

  Widget _buildQATab(Product product) {
    final qaAsync = ref.watch(productQAProvider(product.id));

    return Column(
      children: [
        // Ask question form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qaQuestionController,
                  decoration: const InputDecoration(
                    hintText: 'Ask a question about this product...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isAskingQuestion ? null : () => _askQuestion(product.id),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                child: _isAskingQuestion
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Ask'),
              ),
            ],
          ),
        ),
        const Divider(),
        qaAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No questions yet.', style: TextStyle(color: AppTheme.warmGray)),
              );
            }
            return Column(
              children: questions.map((q) => _QAData(q)).map((qa) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.help_outline, size: 16, color: AppTheme.primaryPink),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(qa.question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('${qa.userName} • ${qa.createdAt}', style: const TextStyle(fontSize: 10, color: AppTheme.warmGray)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (qa.isAnswered) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.reply, size: 16, color: AppTheme.successGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(qa.answer!, style: const TextStyle(fontSize: 12, color: AppTheme.charcoal)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(),
                  ],
                ),
              )).toList(),
            );
          },
          loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Product product) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Quantity
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                SizedBox(width: 28, child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: product.inStock ? () => setState(() => _quantity++) : null,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: product.inStock
                  ? () async {
                      try {
                        await ref.read(cartServiceProvider).addToCart(product.id,
                            quantity: _quantity);
                        ref.invalidate(cartDetailProvider);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$_quantity × ${product.name} added to cart'), backgroundColor: AppTheme.successGreen, behavior: SnackBarBehavior.floating),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorRed),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.accentRose,
              ),
              child: Text(product.inStock ? 'Add to Cart • \$${(product.effectivePrice * _quantity).toStringAsFixed(2)}' : 'Out of Stock'),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageZoom(List<String> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        child: Stack(
          children: [
            CarouselSlider(
              items: images.map((img) => InteractiveViewer(
                minScale: 1, maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: ApiConstants.productImageUrl(img),
                  fit: BoxFit.contain,
                ),
              )).toList(),
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                initialPage: initialIndex,
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewForm(int productId) {
    int rating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Rating: ', style: TextStyle(color: AppTheme.warmGray)),
                  RatingBar.builder(
                    initialRating: 5, minRating: 1, itemSize: 28,
                    itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.mutedGold),
                    onRatingUpdate: (v) => setModalState(() => rating = v.round()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Your Review', hintText: 'Share your experience...'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;
                    try {
                      await ref.read(reviewServiceProvider).createReview(productId, rating, commentController.text);
                      ref.invalidate(productReviewsProvider(productId));
                      ref.invalidate(reviewEligibilityProvider(productId));
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review submitted!'), backgroundColor: AppTheme.successGreen),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
                      }
                    }
                  },
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _askQuestion(int productId) async {
    final q = _qaQuestionController.text.trim();
    if (q.isEmpty) return;
    setState(() => _isAskingQuestion = true);
    try {
      await ref.read(qaServiceProvider).askQuestion(productId, q);
      _qaQuestionController.clear();
      ref.invalidate(productQAProvider(productId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question submitted!'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    }
    setState(() => _isAskingQuestion = false);
  }

  Future<void> _subscribeStockAlert(int productId) async {
    final email = _stockEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    setState(() => _isSubscribingStock = true);
    try {
      await ref.read(stockAlertServiceProvider).subscribe(productId, email);
      _stockEmailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You\'ll be notified when back in stock!'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    }
    setState(() => _isSubscribingStock = false);
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16, backgroundColor: AppTheme.primaryPink.withOpacity(0.1),
                child: Text(review.userName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Row(
                      children: [
                        RatingBarIndicator(rating: review.rating.toDouble(), itemCount: 5, itemSize: 10,
                            itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.mutedGold)),
                        const SizedBox(width: 8),
                        Text(review.createdAt, style: const TextStyle(fontSize: 10, color: AppTheme.warmGray)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(color: AppTheme.charcoal, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class _ProductDetailSkeleton extends StatelessWidget {
  const _ProductDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(expandedHeight: 400, flexibleSpace: FlexibleSpaceBar(background: Container(color: Colors.white))),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(12, (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(height: 16, color: Colors.white, width: double.infinity),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
