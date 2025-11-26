import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'endpoints.dart';
import 'constants.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  /// Salva novos tokens após login ou refresh
  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  /// Retorna o token de acesso atual
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessKey);
  }

  /// Retorna o token de refresh atual
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  /// Remove todos os tokens (logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  /// Tenta renovar o token de acesso usando o refresh token
  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final url = Uri.parse('$baseUrl${Endpoints.authRefreshToken}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveTokens(data['access_token'], data['refresh_token']);
      return true;
    } else {
      // Se a renovação falhar, a sessão é encerrada
      await clearTokens();
      return false;
    }
  }
}
