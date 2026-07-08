import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/models/category.dart';
import '../../core/api/product_service.dart';
import '../../core/api/category_service.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/skeletons.dart';

final productsListProvider = FutureProvider.family<ProductListResponse, ProductFilters>(
  (ref, filters) {
    return ref.watch(productServiceProvider).getProducts(
          category: filters.category,
          search: filters.search,
          minPrice: filters.minPrice,
          maxPrice: filters.maxPrice,
          sortBy: filters.sortBy,
          page: filters.page,
        );
  },
);

final productFiltersProvider = StateProvider<ProductFilters>((ref) {
  return ProductFilters();
});

class ProductFilters {
  final String? category;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final int page;

  const ProductFilters({
    this.category,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.page = 1,
  });

  ProductFilters copyWith({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? page,
    bool clearCategory = false,
    bool clearPrice = false,
  }) {
    return ProductFilters(
      category: clearCategory ? null : (category ?? this.category),
      search: search ?? this.search,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
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
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(productFiltersProvider);
    final productsAsync = ref.watch(productsListProvider(filters));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryPink),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productFiltersProvider.notifier).state =
                              filters.copyWith(search: null);
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                ref.read(productFiltersProvider.notifier).state =
                    filters.copyWith(search: value);
              },
            ),
          ),
          // Category chips
          SizedBox(
            height: 44,
            child: categoriesAsync.when(
              data: (categories) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isAll = _selectedCategory == null;
                    return FilterChip(
                      label: const Text('All'),
                      selected: isAll,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                        ref.read(productFiltersProvider.notifier).state =
                            filters.copyWith(clearCategory: true);
                      },
                      selectedColor: AppTheme.primaryPink.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryPink,
                    );
                  }
                  final cat = categories[index - 1];
                  final isSelected = _selectedCategory == cat.slug;
                  return FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (_) {
                      final newCat = isSelected ? null : cat.slug;
                      setState(() => _selectedCategory = newCat);
                      ref.read(productFiltersProvider.notifier).state =
                          filters.copyWith(
                        category: newCat,
                        clearCategory: isSelected,
                      );
                    },
                    selectedColor: AppTheme.primaryPink.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryPink,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          // Sort bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${filters.page} results',
                    style: const TextStyle(color: AppTheme.warmGray, fontSize: 12)),
                const Spacer(),
                _SortButton(
                  label: 'Sort',
                  current: filters.sortBy,
                  onSelected: (sort) {
                    ref.read(productFiltersProvider.notifier).state =
                        filters.copyWith(sortBy: sort);
                  },
                ),
              ],
            ),
          ),
          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (response) {
                if (response.products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.spa_outlined,
                    title: 'No products found',
                    subtitle: 'Try adjusting your filters or search',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: response.products.length,
                  itemBuilder: (context, index) =>
                      ProductCard(product: response.products[index]),
                );
              },
              loading: () => const ProductGridSkeleton(),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                subtitle: e.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(productsListProvider(filters)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      ref.read(productFiltersProvider.notifier).state =
                          ProductFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'price_asc',
                  'price_desc',
                  'rating',
                  'newest',
                  'name',
                ].map((sort) {
                  final filters = ref.read(productFiltersProvider);
                  final isSelected = filters.sortBy == sort;
                  return ChoiceChip(
                    label: Text(sort.replaceAll('_', ' ').toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(productFiltersProvider.notifier).state =
                          filters.copyWith(sortBy: isSelected ? null : sort);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final String? current;
  final Function(String) onSelected;

  const _SortButton({
    required this.label,
    this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      child: Row(
        children: [
          Text(current != null ? current.replaceAll('_', ' ').toUpperCase() : label,
              style: const TextStyle(fontSize: 12)),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
      itemBuilder: (_) => [
        'price_asc',
        'price_desc',
        'rating',
        'newest',
        'name',
      ].map((s) => PopupMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase()))).toList(),
    );
  }
}
