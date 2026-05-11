import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/host/models/host_booking_model.dart';

/// Fetches and manages host bookings via API
class HostBookingsRepository {
  HostBookingsRepository(this._getToken);

  final Future<String?> Function() _getToken;

  Future<HostBookingsResponse?> fetchBookings({
    String? status,
    String? dateFrom,
    String? dateTo,
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
    if (dateFrom != null && dateFrom.isNotEmpty) queryParams['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) queryParams['date_to'] = dateTo;

    final uri = Uri.parse(ApiConfig.url('/host/bookings'))
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
      return HostBookingsResponse.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> approveBooking(int bookingId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(ApiConfig.url('/host/bookings/$bookingId/approve')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> rejectBooking(int bookingId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(ApiConfig.url('/host/bookings/$bookingId/reject')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> cancelBooking(int bookingId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(ApiConfig.url('/host/bookings/$bookingId/cancel')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<HostBooking?> fetchBookingDetail(int bookingId) async {
    if (!ApiConfig.useApi) return null;

    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(ApiConfig.url('/host/bookings/$bookingId')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['message'] != null) return null;
      return HostBooking.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}

final hostBookingsRepositoryProvider = Provider<HostBookingsRepository>((ref) {
  return HostBookingsRepository(() => AuthController.getStoredToken());
});
