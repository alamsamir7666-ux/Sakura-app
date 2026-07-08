import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/category.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.watch(apiClientProvider));
});

class CategoryService {
  final ApiClient _client;

  CategoryService(this._client);

  Future<List<Category>> getCategories() async {
    final response = await _client.get('/categories');
    return (response.data as List<dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await _client.post('/categories', data: data);
    return Category.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await _client.put('/categories/$id', data: data);
    return Category.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await _client.delete('/categories/$id');
  }
}
