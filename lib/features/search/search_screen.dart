import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../core/api/product_service.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Product> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final response = await ref
          .read(productServiceProvider)
          .getProducts(search: query);
      setState(() => _results = response.products);
      ref.read(searchHistoryProvider.notifier).addSearch(query);
    } catch (_) {
      setState(() => _results = []);
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _results = []);
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isNotEmpty
              ? GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _results.length,
                  itemBuilder: (context, index) =>
                      ProductCard(product: _results[index]),
                )
              : _controller.text.isEmpty
                  ? Column(
                      children: [
                        if (history.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Recent Searches',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () => ref
                                      .read(searchHistoryProvider
                                          .notifier)
                                      .clearHistory(),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          ),
                          ...history.map((query) => ListTile(
                                leading:
                                    const Icon(Icons.history),
                                title: Text(query),
                                onTap: () {
                                  _controller.text = query;
                                  _search(query);
                                },
                              )),
                        ],
                      ],
                    )
                  : const Center(
                      child: Text('No results found',
                          style:
                              TextStyle(color: AppTheme.warmGray)),
                    ),
    );
  }
}
