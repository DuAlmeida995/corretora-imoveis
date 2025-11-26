import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';
import 'dart:io';

import 'constants.dart';

class ApiClient {
  Future<dynamic> get(String endpoint,
      {bool requireAuth = false, Map<String, dynamic>? queryParams}) async {
    Uri url = Uri.parse('$baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams =
          queryParams.map((key, value) => MapEntry(key, value.toString()));

      url = url.replace(queryParameters: stringParams);
    }

    final headers = await _buildHeaders(requireAuth);

    print('>>> REQ GET: $url');

    final response = await http.get(url, headers: headers);
    return await _handleResponse(
        response,
        () =>
            get(endpoint, requireAuth: requireAuth, queryParams: queryParams));
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body,
      {bool requireAuth = false,
      bool isLoginRoute = false,
      bool isAuthFlowRoute = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    print('--- INÍCIO LOG REQUISIÇÃO ---');
    print('>>> REQ POST para: $endpoint');
    print('>>> JSON ENVIADO: ${json.encode(body)}');
    print('----------------------------');

    final response =
        await http.post(url, headers: headers, body: json.encode(body));
    return await _handleResponse(
        response,
        () => post(endpoint, body,
            requireAuth: requireAuth,
            isLoginRoute: isLoginRoute,
            isAuthFlowRoute: isAuthFlowRoute),
        isLoginRoute: isLoginRoute,
        isAuthFlowRoute: isAuthFlowRoute);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body,
      {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _buildHeaders(requireAuth);

    print('--- INÍCIO LOG REQUISIÇÃO (PUT) ---');
    print('>>> URL: $url');
    print('>>> BODY ENVIADO: ${json.encode(body)}');
    print('-----------------------------------');

    final response =
        await http.put(url, headers: headers, body: json.encode(body));
    return await _handleResponse(
        response, () => put(endpoint, body, requireAuth: requireAuth));
  }

  Future<dynamic> delete(String endpoint,
      {bool requireAuth = true, Map<String, dynamic>? queryParams}) async {
    Uri url = Uri.parse('$baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams =
          queryParams.map((key, value) => MapEntry(key, value.toString()));
      url = url.replace(queryParameters: stringParams);
    }

    final headers = await _buildHeaders(requireAuth);

    print('>>> REQ DELETE: $url');

    final response = await http.delete(url, headers: headers);

    return await _handleResponse(
        response,
        () => delete(endpoint,
            requireAuth: requireAuth, queryParams: queryParams));
  }

  Future<Map<String, dynamic>> uploadFile(String endpoint, File file,
      {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    final headers = await _buildHeaders(requireAuth);
    request.headers.addAll(headers);

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_image_url',
        file.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return await _handleResponse(
        response, () => uploadFile(endpoint, file, requireAuth: requireAuth));
  }

  Future<Map<String, dynamic>> uploadMultipleFiles(
      String endpoint, String fieldName, String matricula, List<File> files,
      {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    final headers = await _buildHeaders(requireAuth);
    request.headers.addAll(headers);

    request.fields['matricula'] = matricula;

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return await _handleResponse(
        response,
        () => uploadMultipleFiles(endpoint, fieldName, matricula, files,
            requireAuth: requireAuth));
  }

  // --- helpers ---

  Future<Map<String, String>> _buildHeaders(bool requireAuth) async {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await TokenManager.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _handleResponse(
      http.Response response, Future<dynamic> Function() retryFn,
      {bool isLoginRoute = false, bool isAuthFlowRoute = false}) async {
    print('--- INÍCIO LOG RESPOSTA ---');
    print('<<< ENDPOINT: ${response.request!.url.path}');
    print('<<< STATUS CODE: ${response.statusCode}');
    print('<<< CORPO BRUTO RECEBIDO: ${response.body}');
    print('----------------------------');

    if (response.statusCode == 401) {
      if (isLoginRoute) {
        throw Exception('Credenciais inválidas. Verifique CPF e senha.');
      }

      if (isAuthFlowRoute) {
        throw Exception('Credencial ou código inválido. Tente novamente.');
      }

      final refreshed = await TokenManager.refreshAccessToken();
      if (refreshed) {
        return await retryFn();
      }

      throw Exception('Sessão expirada. Faça login novamente.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else {
      String defaultMessage =
          'Erro ${response.statusCode}: Falha na requisição.';
      String specificMessage = defaultMessage;

      try {
        if (response.body.isNotEmpty) {
          final errorData = json.decode(response.body);

          if (errorData is Map) {
            if (errorData.containsKey('message')) {
              specificMessage = errorData['message'].toString();
            } else if (errorData.containsKey('error')) {
              specificMessage = errorData['error'].toString();
            } else {
              specificMessage = response.body;
            }
          } else {
            specificMessage = response.body;
          }
        }
      } catch (e) {
        specificMessage = defaultMessage;
      }

      throw Exception(specificMessage);
    }
  }
}
