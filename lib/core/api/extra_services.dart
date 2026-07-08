import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user.dart';
import '../models/coupon.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService(ref.watch(apiClientProvider));
});

class ReviewService {
  final ApiClient _client;
  ReviewService(this._client);

  Future<List<Review>> getReviews(int productId) async {
    final response = await _client.get('/reviews/$productId');
    return (response.data as List<dynamic>)
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Review> createReview(int productId, int rating, String comment) async {
    final response = await _client.post(
      '/reviews/$productId',
      data: {'rating': rating, 'comment': comment},
    );
    return Review.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Review> updateReview(int reviewId, int rating, String comment) async {
    final response = await _client.put(
      '/reviews/$reviewId',
      data: {'rating': rating, 'comment': comment},
    );
    return Review.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteReview(int productId, int reviewId) async {
    await _client.delete('/reviews/$productId/$reviewId');
  }

  Future<ReviewEligibility> getEligibility(int productId) async {
    final response = await _client.get('/reviews/$productId/eligibility');
    return ReviewEligibility.fromJson(response.data as Map<String, dynamic>);
  }
}

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  return WishlistService(ref.watch(apiClientProvider));
});

class WishlistService {
  final ApiClient _client;
  WishlistService(this._client);

  Future<List<dynamic>> getWishlist() async {
    final response = await _client.get('/wishlist');
    return response.data as List<dynamic>;
  }

  Future<void> addToWishlist(int productId) async {
    await _client.post('/wishlist/$productId');
  }

  Future<void> removeFromWishlist(int productId) async {
    await _client.delete('/wishlist/$productId');
  }
}

final couponServiceProvider = Provider<CouponService>((ref) {
  return CouponService(ref.watch(apiClientProvider));
});

class CouponService {
  final ApiClient _client;
  CouponService(this._client);

  Future<Coupon> validateCoupon(String code, double orderAmount) async {
    final response = await _client.post(
      '/coupons/validate',
      data: {'code': code, 'orderAmount': orderAmount},
    );
    return Coupon.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Coupon>> getCoupons() async {
    final response = await _client.get('/coupons');
    return (response.data as List<dynamic>)
        .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Coupon> createCoupon(Map<String, dynamic> data) async {
    final response = await _client.post('/coupons', data: data);
    return Coupon.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCoupon(int id) async {
    await _client.delete('/coupons/$id');
  }
}

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.watch(apiClientProvider));
});

class AdminService {
  final ApiClient _client;
  AdminService(this._client);

  Future<dynamic> getDashboard() async {
    final response = await _client.get('/admin/dashboard');
    return response.data;
  }

  Future<List<dynamic>> getAllOrders({String? status, int? page}) async {
    final response = await _client.get(
      '/admin/orders',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    return response.data as List<dynamic>;
  }

  Future<dynamic> updateOrderStatus(int id, String status,
      {String? reason}) async {
    final response = await _client.put(
      '/admin/orders/$id/status',
      data: {'orderStatus': status, if (reason != null) 'cancellationReason': reason},
    );
    return response.data;
  }

  Future<dynamic> updatePaymentStatus(int id, String status) async {
    final response = await _client.put(
      '/admin/orders/$id/payment',
      data: {'paymentStatus': status},
    );
    return response.data;
  }

  Future<List<dynamic>> getAllUsers() async {
    final response = await _client.get('/admin/users');
    return response.data as List<dynamic>;
  }

  Future<dynamic> toggleUserBlock(int id, bool isBlocked) async {
    final response = await _client.put(
      '/admin/users/$id/block',
      data: {'isBlocked': isBlocked},
    );
    return response.data;
  }

  Future<List<dynamic>> getAllReviews() async {
    final response = await _client.get('/admin/reviews');
    return response.data as List<dynamic>;
  }
}
