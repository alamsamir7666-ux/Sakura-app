import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/cart.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService(ref.watch(apiClientProvider));
});

class CartService {
  final ApiClient _client;

  CartService(this._client);

  Future<Cart> getCart() async {
    final response = await _client.get('/cart');
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Cart> addToCart(int productId, {int quantity = 1}) async {
    final response = await _client.post(
      '/cart/items',
      data: {'productId': productId, 'quantity': quantity},
    );
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Cart> updateCartItem(int productId, int quantity) async {
    final response = await _client.put(
      '/cart/items/$productId',
      data: {'quantity': quantity},
    );
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Cart> removeFromCart(int productId) async {
    final response = await _client.delete('/cart/items/$productId');
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> clearCart() async {
    await _client.delete('/cart');
  }
}
