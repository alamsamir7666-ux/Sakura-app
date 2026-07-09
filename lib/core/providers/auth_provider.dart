import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../api/api_client.dart';
import '../config/app_config.dart';

final clerkPublishableKeyProvider = Provider<String>((ref) {
  final config = AppConfig.fromEnvironment();
  return config.clerkPublishableKey;
});

final authStateProvider = Provider<ClerkAuthState?>((ref) {
  // Access via ClerkAuthStateScope in widget tree
  throw UnimplementedError('Use ClerkAuthBuilder or ClerkAuthStateScope to access auth state');
});

final authProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

class AuthService {
  final ApiClient _client;
  AuthService(this._client);

  Future<bool> isAdmin() async {
    try {
      final response = await _client.get('/users/me');
      return response.data['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }
}
