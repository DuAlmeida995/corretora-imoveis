// lib/core/repositories/authentication_repository.dart

import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../api/token_manager.dart';
import '../../data/models/corretor_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AuthenticationRepository {
  static const String _userProfileKey = 'current_user_profile';
  final ApiClient _apiClient = ApiClient();

  // LOGIN
  Future<CorretorModel> login(String cpf, String password) async {
    final responseData = await _apiClient.post(
        Endpoints.authLogin, {'cpf': cpf, 'password': password},
        isLoginRoute: true);

    // Salva os tokens localmente (JWT access + refresh)
    await TokenManager.saveTokens(
      responseData['access_token'],
      responseData['refresh_token'],
    );

    try {
      final user = responseData['user'];

      final CorretorModel corretor = CorretorModel(
          prenome: user['prenome'],
          sobrenome: user['sobrenome'],
          cpf: cpf,
          email: user['email'],
          telefone: user['telefone'],
          dataNascimento: user['dataNascimento'],
          creci: user['creci'],
          especialidade: user['especialidade'],
          regiaoAtuacao: user['regiaoAtuacao'],
          profileImageUrl: user['profile_image_url']);

      final prefs = await SharedPreferences.getInstance(); // API Legada
      prefs.setString(_userProfileKey, json.encode(corretor.toJson()));

      return corretor;
    } catch (e) {
      throw Exception("Erro ao mapear dados do corretor: $e");
    }
  }

  Future<CorretorModel?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userProfileKey);

    if (userJson == null) {
      return null;
    }

    try {
      final Map<String, dynamic> userMap = json.decode(userJson);
      return CorretorModel(
          prenome: userMap['prenome'],
          sobrenome: userMap['sobrenome'],
          cpf: userMap['cpf'],
          email: userMap['email'],
          telefone: userMap['telefone'],
          dataNascimento: userMap['dataNascimento'] ?? '',
          creci: userMap['creci'] ?? '',
          especialidade: userMap['especialidade'] ?? '',
          regiaoAtuacao: userMap['regiaoAtuacao'] ?? '',
          profileImageUrl: userMap['profile_image_url'] ?? '');
    } catch (e) {
      print("Falha ao decodificar perfil salvo: $e");
      return null;
    }
  }

  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    final responseData = await _apiClient
        .uploadFile(Endpoints.userUploadPicture, imageFile, requireAuth: true);

    return responseData['url'] as String;
  }

  /// LOGOUT
  Future<void> logout() async {
    await TokenManager.clearTokens();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userProfileKey);
  }

  /// CADASTRO
  Future<void> registerUser(Map<String, dynamic> userData) async {
    await _apiClient.post(
      Endpoints.authRegister,
      userData,
      requireAuth: false,
    );
  }

  /// SOLICITAR CÓDIGO OTP
  Future<void> requestOtp(String cpf) async {
    await _apiClient.post(
      Endpoints.authRequestOtp,
      {'cpf': cpf},
    );
  }

  /// VERIFICAR CÓDIGO OTP
  Future<void> verifyOtp(String cpf, String otpCode) async {
    await _apiClient.post(
      Endpoints.authVerifyOtp,
      {'cpf': cpf, 'otp_code': otpCode},
      isAuthFlowRoute: true,
    );
  }

  /// RESETAR SENHA
  Future<void> resetPassword(
      String cpf, String otpCode, String newPassword) async {
    await _apiClient.post(
      Endpoints.authResetPassword,
      {
        'cpf': cpf,
        'otp_code': otpCode,
        'new_password': newPassword,
      },
      isAuthFlowRoute: true,
    );
  }

  /// VERIFICAR SE EXISTE USUÁRIO LOGADO
  Future<bool> isLoggedIn() async {
    final token = await TokenManager.getAccessToken();
    return token != null;
  }

  /// RENOVAR TOKEN MANUALMENTE
  Future<bool> refreshSession() async {
    return await TokenManager.refreshAccessToken();
  }

  Future<CorretorModel> updateCorretorProfile(
      CorretorModel updatedCorretor) async {
    final Map<String, dynamic> userDataMap = updatedCorretor.toJson();

    try {
      await _apiClient.put(
        Endpoints.userUpdateProfile,
        userDataMap,
        requireAuth: true,
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_userProfileKey, json.encode(updatedCorretor.toJson()));

      return updatedCorretor;
    } catch (e) {
      throw Exception('Falha ao atualizar perfil: $e');
    }
  }
}
