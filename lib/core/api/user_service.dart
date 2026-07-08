import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user.dart';
import '../models/address.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(apiClientProvider));
});

class UserService {
  final ApiClient _client;

  UserService(this._client);

  Future<UserProfile> getProfile() async {
    final response = await _client.get('/users/me');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/users/me', data: data);
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Address>> getAddresses() async {
    final response = await _client.get('/users/me/addresses');
    return (response.data as List<dynamic>)
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Address> addAddress(Map<String, dynamic> data) async {
    final response = await _client.post('/users/me/addresses', data: data);
    return Address.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Address> updateAddress(int id, Map<String, dynamic> data) async {
    final response = await _client.put('/users/me/addresses/$id', data: data);
    return Address.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteAddress(int id) async {
    await _client.delete('/users/me/addresses/$id');
  }
}
