import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/host/models/host_dashboard_model.dart';

/// Fetches host dashboard data from GET /api/host/dashboard
class HostDashboardRepository {
  HostDashboardRepository(this._getToken);

  final Future<String?> Function() _getToken;

  Future<HostDashboardModel?> fetchDashboard() async {
    if (!ApiConfig.useApi) return null;

    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(ApiConfig.url('/host/dashboard')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return HostDashboardModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}

final hostDashboardRepositoryProvider = Provider<HostDashboardRepository>((ref) {
  return HostDashboardRepository(() => AuthController.getStoredToken());
});
