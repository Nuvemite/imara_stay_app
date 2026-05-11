import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// API client for Laravel backend
/// Handles GET, POST, PUT, DELETE with auth headers
class ApiClient {
  ApiClient({String? token}) : _token = token;

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Map<String, String> get _authHeaders => {
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> get(String path, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse(ApiConfig.url(path));
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return http
        .get(uri, headers: _headers)
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    return http
        .post(
          Uri.parse(ApiConfig.url(path)),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    return http
        .put(
          Uri.parse(ApiConfig.url(path)),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
  }

  Future<http.Response> delete(String path) async {
    return http
        .delete(Uri.parse(ApiConfig.url(path)), headers: _headers)
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
  }

  /// Multipart POST for file uploads (e.g. avatar)
  Future<http.StreamedResponse> postMultipart(
    String path, {
    required String fieldName,
    required File file,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.url(path)),
    );
    request.headers.addAll(_authHeaders);
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    return request.send().timeout(Duration(seconds: ApiConfig.timeoutSeconds));
  }
}
