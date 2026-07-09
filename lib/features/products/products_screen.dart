import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/models/category.dart';
import '../../core/api/product_service.dart';
import '../../core/api/cart_service.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/skeletons.dart';
import '../../shared/widgets/common_widgets.dart';

final productsListProvider = FutureProvider.family<ProductListResponse, ProductFilters>((ref, filters) {
  return ref.watch(productServiceProvider).getProducts(
    category: filters.category,
    search: filters.search,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    minRating: filters.minRating,
    sortBy: filters.sortBy,
    page: filters.page,
    limit: 12,
  );
});

final productFiltersProvider = StateProvider<ProductFilters>((ref) => ProductFilters());

class ProductFilters {
  final String? category;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  double? minRating;
  final String? sortBy;
  final int page;

  ProductFilters({
    this.category, this.search, this.minPrice, this.maxPrice,
    this.minRating, this.sortBy, this.page = 1,
  });

  ProductFilters copyWith({
    String? category, String? search, double? minPrice, double? maxPrice,
    double? minRating, String? sortBy, int? page,
    bool clearCategory = false, bool clearPrice = false, bool clearRating = false,
  }) {
    return ProductFilters(
      category: clearCategory ? null : (category ?? this.category),
      search: search ?? this.search,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
    );
  }
}

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String? _selectedCategory;
  bool _isGridView = true;
  final List<Product> _allProducts = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final filters = ref.read(productFiltersProvider);
      ref.read(productFiltersProvider.notifier).state = filters.copyWith(
        search: value.isNotEmpty ? value : null,
        page: 1,
      );
      _allProducts.clear();
      _hasMore = true;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final filters = ref.read(productFiltersProvider);
    ref.read(productFiltersProvider.notifier).state = filters.copyWith(
      page: filters.page + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(productFiltersProvider);
    final productsAsync = ref.watch(productsListProvider(filters));
    final categoriesAsync = ref.watch(categoriesProvider);

    // Auto-append products from pagination
    productsAsync.whenData((response) {
      if (response.page == 1) {
        _allProducts.clear();
      }
      for (final p in response.products) {
        if (!_allProducts.any((e) => e.id == p.id)) {
          _allProducts.add(p);
        }
      }
      _hasMore = response.page < response.totalPages;
      _isLoadingMore = false;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryPink),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          // Categories
          SizedBox(
            height: 44,
            child: categoriesAsync.when(
              data: (categories) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    final isAll = _selectedCategory == null;
                    return FilterChip(
                      label: const Text('All', style: TextStyle(fontSize: 12)),
                      selected: isAll,
                      onSelected: (_) => _selectCategory(null),
                      selectedColor: AppTheme.primaryPink.withOpacity(0.15),
                      checkmarkColor: AppTheme.primaryPink,
                      visualDensity: VisualDensity.compact,
                    );
                  }
                  final cat = categories[i - 1];
                  final isSel = _selectedCategory == cat.slug;
                  return FilterChip(
                    label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                    selected: isSel,
                    onSelected: (_) => _selectCategory(isSel ? null : cat.slug),
                    selectedColor: AppTheme.primaryPink.withOpacity(0.15),
                    checkmarkColor: AppTheme.primaryPink,
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
              loading: () => const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          // Sort + results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text('${_allProducts.length} results',
                    style: const TextStyle(color: AppTheme.warmGray, fontSize: 11)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showSortMenu(context),
                  child: Row(
                    children: [
                      Text(filters.sortBy != null ? _sortLabel(filters.sortBy!) : 'Sort',
                          style: const TextStyle(fontSize: 12, color: AppTheme.primaryPink)),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primaryPink),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Products
          Expanded(
            child: productsAsync.when(
              data: (_) => _allProducts.isEmpty
                  ? EmptyState(icon: Icons.spa_outlined, title: 'No products', subtitle: 'Try adjusting filters')
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.read(productFiltersProvider.notifier).state = filters.copyWith(page: 1);
                        _allProducts.clear();
                        _hasMore = true;
                        ref.invalidate(productsListProvider(filters));
                      },
                      child: _isGridView ? _buildGrid() : _buildList(),
                    ),
              loading: () => _allProducts.isEmpty ? const ProductGridSkeleton() : _buildGrid(),
              error: (e, _) => EmptyState(
                  icon: Icons.error_outline, title: 'Error', subtitle: e.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(productsListProvider(filters))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemCount: _allProducts.length + (_isLoadingMore ? 2 : 0),
      itemBuilder: (context, i) {
        if (i >= _allProducts.length) return const ProductCardSkeleton();
        return ProductCard(product: _allProducts[i]);
      },
    );
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _allProducts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _allProducts.length) return const Padding(
          padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        return ProductListItem(
          product: _allProducts[i],
          onAddToCart: () => _quickAddToCart(_allProducts[i]),
        );
      },
    );
  }

  Future<void> _quickAddToCart(Product product) async {
    try {
      await ref.read(cartServiceProvider).addToCart(product.id);
      ref.invalidate(cartDetailProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} added to cart'), backgroundColor: AppTheme.successGreen, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _selectCategory(String? slug) {
    setState(() => _selectedCategory = slug);
    final filters = ref.read(productFiltersProvider);
    ref.read(productFiltersProvider.notifier).state = filters.copyWith(
      category: slug, clearCategory: slug == null, page: 1,
    );
    _allProducts.clear();
    _hasMore = true;
  }

  void _showFilterSheet(BuildContext context) {
    final filters = ref.read(productFiltersProvider);
    double minPrice = filters.minPrice ?? 0;
    double maxPrice = filters.maxPrice ?? 500;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      ref.read(productFiltersProvider.notifier).state = ProductFilters();
                      _allProducts.clear();
                      _hasMore = true;
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
              RangeSlider(
                values: RangeValues(minPrice, maxPrice),
                min: 0, max: 500, divisions: 50,
                activeColor: AppTheme.primaryPink,
                labels: RangeLabels('\$${minPrice.toInt()}', '\$${maxPrice.toInt()}'),
                onChanged: (v) => setModalState(() {
                  minPrice = v.start; maxPrice = v.end;
                }),
              ),
              const SizedBox(height: 16),
              const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [4, 3, 2].map((r) {
                  final sel = filters.minRating == r.toDouble();
                  return ChoiceChip(
                    label: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('$r', style: const TextStyle(fontSize: 12)),
                      const Icon(Icons.star, size: 12, color: AppTheme.mutedGold),
                      const Text(' & up', style: TextStyle(fontSize: 10)),
                    ]),
                    selected: sel,
                    onSelected: (_) => setModalState(() {
                      filters.minRating = sel ? null : r.toDouble();
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(productFiltersProvider.notifier).state = filters.copyWith(
                      minPrice: minPrice > 0 ? minPrice : null,
                      maxPrice: maxPrice < 500 ? maxPrice : null,
                      clearPrice: minPrice == 0 && maxPrice == 500,
                      page: 1,
                    );
                    _allProducts.clear();
                    _hasMore = true;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    final filters = ref.read(productFiltersProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...{
              '': 'Default',
              'price_asc': 'Price: Low to High',
              'price_desc': 'Price: High to Low',
              'rating': 'Highest Rated',
              'newest': 'Newest First',
              'name': 'Name A-Z',
            }.entries.map((e) {
              final isSel = filters.sortBy == e.key || (filters.sortBy == null && e.key == '');
              return RadioListTile<String>(
                value: e.key,
                groupValue: filters.sortBy ?? '',
                title: Text(e.value, style: const TextStyle(fontSize: 14)),
                activeColor: AppTheme.primaryPink,
                dense: true,
                onChanged: (v) {
                  ref.read(productFiltersProvider.notifier).state = filters.copyWith(
                    sortBy: v!.isEmpty ? null : v, page: 1,
                  );
                  _allProducts.clear();
                  _hasMore = true;
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _sortLabel(String sort) {
    return {
      'price_asc': 'Price ↑',
      'price_desc': 'Price ↓',
      'rating': 'Rating',
      'newest': 'Newest',
      'name': 'Name',
    }[sort] ?? sort;
  }
}
