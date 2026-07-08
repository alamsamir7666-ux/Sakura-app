import 'product.dart';
import 'address.dart';

class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final Product product;

  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  double get total => product.effectivePrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}

class Cart {
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String? couponCode;

  const Cart({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.couponCode,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      couponCode: json['couponCode'] as String?,
    );
  }
}
