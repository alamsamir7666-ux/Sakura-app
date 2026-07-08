import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/order.dart';
import '../models/address.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(apiClientProvider));
});

class OrderService {
  final ApiClient _client;

  OrderService(this._client);

  Future<List<Order>> getOrders() async {
    final response = await _client.get('/orders');
    return (response.data as List<dynamic>)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Order> getOrder(int id) async {
    final response = await _client.get('/orders/$id');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> createOrder({
    required String paymentMethod,
    String? transactionId,
    required AddressBody shippingAddress,
    String? couponCode,
  }) async {
    final response = await _client.post(
      '/orders',
      data: {
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'shippingAddress': shippingAddress.toJson(),
        if (couponCode != null) 'couponCode': couponCode,
      },
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderTracking> trackOrder(String trackingId) async {
    final response = await _client.get('/orders/track/$trackingId');
    return OrderTracking.fromJson(response.data as Map<String, dynamic>);
  }
}
