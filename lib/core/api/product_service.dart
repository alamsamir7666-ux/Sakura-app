import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/product.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(apiClientProvider));
});

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<ProductListResponse> getProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    int page = 1,
    int limit = 12,
  }) async {
    final response = await _client.get(
      '/products',
      queryParameters: {
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (minRating != null) 'minRating': minRating,
        if (sortBy != null) 'sortBy': sortBy,
        'page': page,
        'limit': limit,
      },
    );
    return ProductListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> getProduct(int id) async {
    final response = await _client.get('/products/$id');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Product>> getFeaturedProducts() async {
    final response = await _client.get('/products/featured');
    return (response.data as List<dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HomepageProducts> getHomepageProducts() async {
    final response = await _client.get('/products/homepage');
    return HomepageProducts.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await _client.post('/products', data: data);
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _client.put('/products/$id', data: data);
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await _client.delete('/products/$id');
  }
}
