import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/blog.dart';

final blogServiceProvider = Provider<BlogService>((ref) {
  return BlogService(ref.watch(apiClientProvider));
});

class BlogService {
  final ApiClient _client;
  BlogService(this._client);

  Future<List<BlogPost>> getPosts({int page = 1, int limit = 10}) async {
    final response = await _client.get('/blog', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return (response.data as List<dynamic>)
        .map((e) => BlogPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BlogPost> getPost(int id) async {
    final response = await _client.get('/blog/$id');
    return BlogPost.fromJson(response.data as Map<String, dynamic>);
  }
}

// ── Affiliate ──
final affiliateServiceProvider = Provider<AffiliateService>((ref) {
  return AffiliateService(ref.watch(apiClientProvider));
});

class AffiliateService {
  final ApiClient _client;
  AffiliateService(this._client);

  Future<Map<String, dynamic>?> getProfile() async {
    final response = await _client.get('/affiliates/me');
    return response.data as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> register(String code) async {
    final response = await _client.post('/affiliates', data: {'code': code});
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getCashouts() async {
    final response = await _client.get('/affiliates/me/cashouts');
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> requestCashout(double amount) async {
    final response = await _client.post('/affiliates/me/cashouts', data: {
      'amount': amount,
    });
    return response.data as Map<String, dynamic>;
  }
}

// ── Returns ──
final returnServiceProvider = Provider<ReturnService>((ref) {
  return ReturnService(ref.watch(apiClientProvider));
});

class ReturnService {
  final ApiClient _client;
  ReturnService(this._client);

  Future<List<Map<String, dynamic>>> getReturns() async {
    final response = await _client.get('/returns');
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createReturn(
      int orderId, String reason, String? notes) async {
    final response = await _client.post('/returns', data: {
      'orderId': orderId,
      'reason': reason,
      if (notes != null) 'notes': notes,
    });
    return response.data as Map<String, dynamic>;
  }
}

// ── Newsletter ──
final newsletterServiceProvider = Provider<NewsletterService>((ref) {
  return NewsletterService(ref.watch(apiClientProvider));
});

class NewsletterService {
  final ApiClient _client;
  NewsletterService(this._client);

  Future<void> subscribe(String email) async {
    await _client.post('/newsletter/subscribe', data: {'email': email});
  }

  Future<void> unsubscribe(String email) async {
    await _client.post('/newsletter/unsubscribe', data: {'email': email});
  }
}

// ── Product Variants ──
final variantServiceProvider = Provider<VariantService>((ref) {
  return VariantService(ref.watch(apiClientProvider));
});

class VariantService {
  final ApiClient _client;
  VariantService(this._client);

  Future<List<Map<String, dynamic>>> getVariants(int productId) async {
    final response = await _client.get('/products/$productId/variants');
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }
}

// ── Product Q&A ──
final qaServiceProvider = Provider<QAService>((ref) {
  return QAService(ref.watch(apiClientProvider));
});

class QAService {
  final ApiClient _client;
  QAService(this._client);

  Future<List<Map<String, dynamic>>> getQuestions(int productId) async {
    final response = await _client.get('/products/$productId/questions');
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> askQuestion(
      int productId, String question) async {
    final response = await _client
        .post('/products/$productId/questions', data: {'question': question});
    return response.data as Map<String, dynamic>;
  }
}

// ── Stock Alert ──
final stockAlertServiceProvider = Provider<StockAlertService>((ref) {
  return StockAlertService(ref.watch(apiClientProvider));
});

class StockAlertService {
  final ApiClient _client;
  StockAlertService(this._client);

  Future<void> subscribe(int productId, String email) async {
    await _client.post('/stock-alerts', data: {
      'productId': productId,
      'email': email,
    });
  }

  Future<void> unsubscribe(int id) async {
    await _client.delete('/stock-alerts/$id');
  }

  Future<List<Map<String, dynamic>>> getAlerts() async {
    final response = await _client.get('/stock-alerts');
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }
}

// ── Skin Profile ──
final skinProfileServiceProvider = Provider<SkinProfileService>((ref) {
  return SkinProfileService(ref.watch(apiClientProvider));
});

class SkinProfileService {
  final ApiClient _client;
  SkinProfileService(this._client);

  Future<Map<String, dynamic>?> getProfile() async {
    final response = await _client.get('/skin-profile');
    return response.data as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/skin-profile', data: data);
    return response.data as Map<String, dynamic>;
  }
}
