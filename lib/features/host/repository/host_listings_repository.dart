import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/host/models/host_listing_model.dart';

/// Fetches and manages host listings via API
class HostListingsRepository {
  HostListingsRepository(this._getToken);

  final Future<String?> Function() _getToken;

  Future<HostListingsResponse?> fetchListings({
    String? status,
    int? listingTypeId,
    int page = 1,
    int perPage = 12,
  }) async {
    if (!ApiConfig.useApi) return null;

    final token = await _getToken();
    if (token == null) return null;

    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (status != null && status != 'all') queryParams['status'] = status;
    if (listingTypeId != null && listingTypeId > 0) {
      queryParams['listing_type_id'] = listingTypeId.toString();
    }

    final uri = Uri.parse(ApiConfig.url('/host/listings'))
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['error'] != null) return null;
      return HostListingsResponse.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateStatus(int listingId, String statusSlug) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse(ApiConfig.url('/host/listings/$listingId/status')),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': statusSlug}),
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> deleteListing(int listingId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse(ApiConfig.url('/host/listings/$listingId')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}

final hostListingsRepositoryProvider = Provider<HostListingsRepository>((ref) {
  return HostListingsRepository(() => AuthController.getStoredToken());
});
