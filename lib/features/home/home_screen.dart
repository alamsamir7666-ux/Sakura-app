import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/models/category.dart';
import '../../core/api/product_service.dart';
import '../../core/api/category_service.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/skeletons.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/flash_sale_section.dart';
import '../../core/models/more_models.dart';

final homepageProductsProvider = FutureProvider<HomepageProducts>((ref) {
  return ref.watch(productServiceProvider).getHomepageProducts();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productServiceProvider).getFeaturedProducts();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homepageProductsProvider);
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(context),
              const SizedBox(height: 8),
              _buildFlashSale(context),
              const SizedBox(height: 8),
              _buildCategories(context, ref),
              const SizedBox(height: 8),
              _buildFeaturedSection(context, ref),
              const SizedBox(height: 8),
              _buildTopProducts(context, ref),
              const SizedBox(height: 8),
              _buildBottomProducts(context, ref),
              const SizedBox(height: 8),
              _buildPromoBanner(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.spa, color: AppTheme.primaryPink, size: 24),
          const SizedBox(width: 8),
          const Text('Sakura Beauty',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoal,
                  fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push('/search'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final banners = [
      {
        'title': 'Spring Glow Collection',
        'subtitle': 'Discover the secret to radiant skin',
        'color': AppTheme.secondaryPink,
      },
      {
        'title': 'New Arrivals',
        'subtitle': 'Premium Japanese skincare',
        'color': AppTheme.softGreen.withOpacity(0.5),
      },
      {
        'title': 'Flash Sale',
        'subtitle': 'Up to 40% off on bestsellers',
        'color': AppTheme.mutedGold.withOpacity(0.4),
      },
    ];

    return CarouselSlider(
      items: banners.map((b) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [b['color'] as Color, (b['color'] as Color).withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(Icons.spa,
                    size: 120, color: Colors.white.withOpacity(0.2)),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(b['title'] as String,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.charcoal)),
                    const SizedBox(height: 8),
                    Text(b['subtitle'] as String,
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.warmGray)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRose,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                      ),
                      child: const Text('Shop Now'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlayInterval: const Duration(seconds: 5),
        padEnds: false,
      ),
    );
  }

  Widget _buildFlashSale(BuildContext context) {
    // Static sample flash sales — in production, fetch from API
    final sampleSales = [
      FlashSale(id: 1, productId: 5, salePrice: 19.99, quantity: 50, sold: 32,
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 10)), isActive: true),
      FlashSale(id: 2, productId: 8, salePrice: 24.99, quantity: 30, sold: 8,
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 8)), isActive: true),
    ];
    return FlashSaleSection(sales: sampleSales);
  }

  Widget _buildCategories(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Categories'),
        categoriesAsync.when(
          data: (categories) => SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () => context.push('/products?category=${cat.slug}'),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(cat.icon ?? '🌸',
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(cat.name,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
          loading: () => const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Featured Products',
          onSeeAll: () => context.push('/products'),
        ),
        featured.when(
          data: (products) => SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: products.length,
              itemBuilder: (context, index) => SizedBox(
                width: 180,
                child: ProductCard(product: products[index]),
              ),
            ),
          ),
          loading: () => SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, __) => const SizedBox(
                width: 180,
                child: ProductCardSkeleton(),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTopProducts(BuildContext context, WidgetRef ref) {
    final homepage = ref.watch(homepageProductsProvider);

    return homepage.when(
      data: (data) {
        if (data.top.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Best Sellers'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: data.top.length.clamp(0, 4),
                itemBuilder: (context, index) =>
                    ProductCard(product: data.top[index]),
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        children: [
          const SectionHeader(title: 'Best Sellers'),
          const ProductGridSkeleton(),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomProducts(BuildContext context, WidgetRef ref) {
    final homepage = ref.watch(homepageProductsProvider);

    return homepage.when(
      data: (data) {
        if (data.bottom.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'New Arrivals'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: data.bottom.length.clamp(0, 4),
                itemBuilder: (context, index) =>
                    ProductCard(product: data.bottom[index]),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.accentRose],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join Sakura Rewards',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Earn points on every purchase',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/loyalty'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryPink,
            ),
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }
}
