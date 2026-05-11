import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';

/// KYC repository - host application, identity upload, verification
class KycRepository {
  KycRepository(this._getToken);

  final Future<String?> Function() _getToken;

  /// GET /api/host/application-status
  Future<HostApplicationStatus?> getApplicationStatus() async {
    if (!ApiConfig.useApi) return null;

    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(ApiConfig.url('/host/application-status')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return HostApplicationStatus(
        isHost: data['is_host'] == true,
        hasApplication: data['has_application'] == true,
        status: data['status']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  /// POST /api/host/apply - Apply to become a host
  Future<bool> applyToBecomeHost() async {
    if (!ApiConfig.useApi) return false;

    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(ApiConfig.url('/host/apply')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// POST /api/host/kyc/identity - Upload identity document (backend may need this endpoint)
  Future<bool> uploadIdentityDocument(File file) async {
    if (!ApiConfig.useApi) return false;

    final token = await _getToken();
    if (token == null) return false;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.url('/host/kyc/identity')),
    );
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('identity_document', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// POST /api/user/verify - Mark user as verified (after KYC complete)
  Future<bool> verifyUser() async {
    if (!ApiConfig.useApi) return false;

    final token = await _getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(ApiConfig.url('/user/verify')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    return response.statusCode == 200;
  }
}

class HostApplicationStatus {
  const HostApplicationStatus({
    required this.isHost,
    required this.hasApplication,
    this.status,
  });

  final bool isHost;
  final bool hasApplication;
  final String? status; // pending, approved, rejected
}

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(() => AuthController.getStoredToken());
});
