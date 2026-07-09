import 'product.dart';
import 'address.dart';

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  const OrderItem({required this.id, required this.productId, required this.productName, required this.productImage, required this.quantity, required this.price});

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as int, productId: json['productId'] as int,
    productName: json['productName'] as String, productImage: json['productImage'] as String,
    quantity: json['quantity'] as int, price: (json['price'] as num).toDouble(),
  );
}

class Order {
  final int id;
  final String trackingId;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? transactionId;
  final AddressBody shippingAddress;
  final String? couponCode;
  final double discountAmount;
  final String? cancellationReason;
  final String createdAt;
  final String updatedAt;

  const Order({required this.id, required this.trackingId, required this.userId, required this.items, required this.totalAmount, required this.paymentMethod, required this.paymentStatus, required this.orderStatus, this.transactionId, required this.shippingAddress, this.couponCode, required this.discountAmount, this.cancellationReason, required this.createdAt, required this.updatedAt});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int, trackingId: json['trackingId'] as String,
    userId: json['userId'] as String,
    items: (json['items'] as List<dynamic>).map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paymentMethod: json['paymentMethod'] as String, paymentStatus: json['paymentStatus'] as String,
    orderStatus: json['orderStatus'] as String, transactionId: json['transactionId'] as String?,
    shippingAddress: AddressBody.fromJson(json['shippingAddress'] as Map<String, dynamic>),
    couponCode: json['couponCode'] as String?, discountAmount: (json['discountAmount'] as num).toDouble(),
    cancellationReason: json['cancellationReason'] as String?,
    createdAt: json['createdAt'] as String, updatedAt: json['updatedAt'] as String,
  );
}

class OrderTracking {
  final String trackingId;
  final String orderStatus;
  final String estimatedDelivery;
  final String? courierName;
  final List<OrderTrackingStep> timeline;

  const OrderTracking({required this.trackingId, required this.status, required this.estimatedDelivery, this.courierName, required this.steps});

  factory OrderTracking.fromJson(Map<String, dynamic> json) => OrderTracking(
    trackingId: json['trackingId'] as String, orderStatus: json['status'] as String,
    estimatedDelivery: json['estimatedDelivery'] as String, courierName: json['courierName'] as String?,
    timeline: (json['steps'] as List<dynamic>).map((e) => OrderTrackingStep.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

class OrderTrackingStep {
  final String title;
  final String description;
  final String timestamp;
  final bool isCompleted;

  const OrderTrackingStep({required this.title, required this.description, required this.timestamp, required this.isCompleted});

  factory OrderTrackingStep.fromJson(Map<String, dynamic> json) => OrderTrackingStep(
    title: json['title'] as String, description: json['description'] as String,
    timestamp: json['timestamp'] as String, isCompleted: json['isCompleted'] as bool,
  );
}
