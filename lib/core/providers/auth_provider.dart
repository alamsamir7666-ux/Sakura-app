import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../api/api_client.dart';

final isSignedInProvider = Provider<bool>((ref) {
  return Clerk.session != null;
});

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final session = Clerk.session;
  if (session == null) return null;
  final user = session.user;
  return {
    'id': user.id,
    'email': user.emailAddresses.firstOrNull?.emailAddress,
    'firstName': user.firstName,
    'lastName': user.lastName,
    'imageUrl': user.imageUrl,
  };
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

  Future<void> signOut() async {
    await Clerk.signOut();
  }
}
