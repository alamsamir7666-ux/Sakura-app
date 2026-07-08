import 'product.dart';

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
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

  const Order({
    required this.id,
    required this.trackingId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.transactionId,
    required this.shippingAddress,
    this.couponCode,
    required this.discountAmount,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      trackingId: json['trackingId'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String,
      orderStatus: json['orderStatus'] as String,
      transactionId: json['transactionId'] as String?,
      shippingAddress:
          AddressBody.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      couponCode: json['couponCode'] as String?,
      discountAmount: (json['discountAmount'] as num).toDouble(),
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

class OrderTracking {
  final String trackingId;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String createdAt;
  final String updatedAt;
  final List<TrackingEvent> timeline;

  const OrderTracking({
    required this.trackingId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.timeline,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      trackingId: json['trackingId'] as String,
      orderStatus: json['orderStatus'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TrackingEvent {
  final String status;
  final String label;
  final String? timestamp;
  final bool completed;

  const TrackingEvent({
    required this.status,
    required this.label,
    this.timestamp,
    required this.completed,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      status: json['status'] as String,
      label: json['label'] as String,
      timestamp: json['timestamp'] as String?,
      completed: json['completed'] as bool,
    );
  }
}
