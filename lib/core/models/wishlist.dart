import 'product.dart';

class WishlistItem {
  final int id;
  final int productId;
  final Product product;
  final String addedAt;

  const WishlistItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      addedAt: json['addedAt'] as String,
    );
  }
}
