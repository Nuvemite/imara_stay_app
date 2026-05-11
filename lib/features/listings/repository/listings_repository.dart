import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import '../models/listing_lookups.dart';
import '../models/listing_wizard_state.dart';

/// Repository for creating listings via Laravel API
/// POST /api/listings - create listing
/// POST /api/listings/images - upload images (listing_id, image)
class ListingsRepository {
  ListingsRepository(this._getToken);

  final Future<String?> Function() _getToken;

  ListingLookups? _cachedLookups;

  Future<ListingLookups?> fetchLookups() async {
    if (!ApiConfig.useApi) return null;
    if (_cachedLookups != null) return _cachedLookups;

    final token = await _getToken();
    if (token == null) return null;

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final results = await Future.wait([
        http.get(Uri.parse(ApiConfig.url('/listing-types')), headers: headers),
        http.get(Uri.parse(ApiConfig.url('/room-types')), headers: headers),
        http.get(Uri.parse(ApiConfig.url('/property-types')), headers: headers),
        http.get(Uri.parse(ApiConfig.url('/amenities')), headers: headers),
      ]);

      // Backend returns raw arrays, not {data: [...]}
      final listingTypes = _parseLookupItems(results[0]);
      final roomTypes = _parseLookupItems(results[1]);
      final propertyTypes = _parseLookupItems(results[2]);
      final amenities = _parseLookupItems(results[3]);

      _cachedLookups = ListingLookups(
        listingTypes: listingTypes,
        roomTypes: roomTypes,
        propertyTypes: propertyTypes,
        amenities: amenities,
      );
      return _cachedLookups;
    } catch (_) {
      return null;
    }
  }

  List<LookupItem> _parseLookupItems(http.Response response) {
    if (response.statusCode != 200) return [];
    try {
      final data = jsonDecode(response.body);
      List<dynamic>? items;
      if (data is Map) {
        items = (data['data'] ?? data['items']) as List?;
      } else if (data is List) {
        items = data;
      }
      if (items != null) {
        return items
            .map((e) => LookupItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((e) => e.id > 0)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> createListing(ListingWizardState state) async {
    if (!ApiConfig.useApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {'id': 1, 'title': state.title};
    }

    final token = await _getToken();
    if (token == null) throw Exception('Please log in to create a listing');

    final lookups = await fetchLookups();
    final payload = state.toApiPayload(lookups);
    final response = await http.post(
      Uri.parse(ApiConfig.url('/listings')),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final listing = data is Map ? (data['data'] ?? data) : null;
      final id = listing is Map ? listing['id'] : data['id'];
      if (id != null && state.imagePaths.isNotEmpty) {
        await _uploadImages(token, id, state.imagePaths);
      }
      return listing is Map ? Map<String, dynamic>.from(listing) : {'id': id};
    }

    final body = jsonDecode(response.body);
    if (body is Map && body['errors'] is Map) {
      final errors = body['errors'] as Map<String, dynamic>;
      final messages = errors.entries
          .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
          .join('; ');
      throw Exception(messages.isNotEmpty ? messages : 'Validation failed');
    }
    final msg = body is Map
        ? (body['message'] ?? body['error'] ?? 'Failed to create listing')
        : 'Failed to create listing';
    throw Exception(msg.toString());
  }

  Future<void> _uploadImages(
    String token,
    dynamic listingId,
    List<String> imagePaths,
  ) async {
    for (final path in imagePaths) {
      final file = File(path);
      if (!await file.exists()) continue;
      try {
        final uri = Uri.parse(ApiConfig.url('/listings/images'));
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
        request.fields['listing_id'] = listingId.toString();
        request.files.add(await http.MultipartFile.fromPath('image', file.path));
        final streamed = await request.send();
        final resp = await http.Response.fromStream(streamed);
        if (resp.statusCode < 200 || resp.statusCode >= 300) break;
      } catch (_) {
        break;
      }
    }
  }
}

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(() async {
    final authState = ref.read(authProvider);
    return authState.user?.token;
  });
});
