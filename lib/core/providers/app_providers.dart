import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/product_service.dart';
import '../api/category_service.dart';
import '../api/cart_service.dart';
import '../api/order_service.dart';
import '../api/user_service.dart';
import '../api/extra_services.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/product.dart';

// Cart detail (shared by cart + checkout screens)
final cartDetailProvider = FutureProvider<Cart>((ref) {
  return ref.watch(cartServiceProvider).getCart();
});

// Categories (shared by home + products screens)
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryServiceProvider).getCategories();
});

// Theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Cart state
final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<dynamic>>((ref) {
  return CartNotifier(ref.watch(cartServiceProvider));
});

class CartNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final CartService _service;
  CartNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getCart());
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    state = await AsyncValue.guard(
        () => _service.addToCart(productId, quantity: quantity));
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    state = await AsyncValue.guard(
        () => _service.updateCartItem(productId, quantity));
  }

  Future<void> removeItem(int productId) async {
    state = await AsyncValue.guard(() => _service.removeFromCart(productId));
  }

  Future<void> clearCart() async {
    state = await AsyncValue.guard(() => _service.clearCart());
  }
}

// Wishlist
final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<int>>((ref) {
  return WishlistNotifier(ref.watch(wishlistServiceProvider));
});

class WishlistNotifier extends StateNotifier<Set<int>> {
  final WishlistService _service;
  WishlistNotifier(this._service) : super({}) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      final items = await _service.getWishlist();
      state = items
          .map<int>((e) => (e as Map<String, dynamic>)['productId'] as int)
          .toSet();
    } catch (_) {}
  }

  bool isInWishlist(int productId) => state.contains(productId);

  Future<void> toggle(int productId) async {
    if (state.contains(productId)) {
      await _service.removeFromWishlist(productId);
      state = {...state}..remove(productId);
    } else {
      await _service.addToWishlist(productId);
      state = {...state, productId};
    }
  }
}

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('search_history') ?? [];
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    final updated = [query, ...state.where((s) => s != query)].take(10).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', updated);
  }

  Future<void> clearHistory() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
  }
}
