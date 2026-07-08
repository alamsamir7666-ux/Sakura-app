import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/api/product_service.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/product_card.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final List<Product?> _products = [null, null, null];
  final _controllers =
      List.generate(3, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _searchProduct(int slot, String query) async {
    if (query.isEmpty) return;
    try {
      final response = await ref
          .read(productServiceProvider)
          .getProducts(search: query, limit: 1);
      if (response.products.isNotEmpty) {
        setState(() => _products[slot] = response.products.first);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Products')),
      body: _products.every((p) => p == null)
          ? EmptyState(
              icon: Icons.compare_arrows,
              title: 'Compare Products',
              subtitle:
                  'Search and select products to compare their features side by side',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Search fields
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: _products[i] != null
                            ? Stack(
                                children: [
                                  ProductCard(product: _products[i]!),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: AppTheme.errorRed),
                                      onPressed: () => setState(
                                          () => _products[i] = null),
                                    ),
                                  ),
                                ],
                              )
                            : TextField(
                                controller: _controllers[i],
                                decoration: InputDecoration(
                                  hintText: 'Search product...',
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search,
                                        size: 18),
                                    onPressed: () => _searchProduct(
                                        i, _controllers[i].text),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Comparison table
                if (_products.any((p) => p != null))
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(3),
                          3: FlexColumnWidth(3),
                        },
                        children: [
                          _compareRow('Price', (p) =>
                              '\$${p.effectivePrice.toStringAsFixed(2)}'),
                          _compareRow(
                              'Rating', (p) => '${p.averageRating} ⭐'),
                          _compareRow('Category',
                              (p) => p.category),
                          _compareRow(
                              'Stock', (p) => '${p.stock}'),
                          _compareRow('Texture',
                              (p) => p.texture ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  TableRow _compareRow(
      String label, String Function(Product) getValue) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...List.generate(3, (i) {
          final p = _products[i];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(p != null ? getValue(p) : '-',
                style: const TextStyle(fontSize: 13)),
          );
        }),
      ],
    );
  }
}
