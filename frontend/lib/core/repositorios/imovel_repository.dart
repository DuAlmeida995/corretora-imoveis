import 'dart:convert';
import 'dart:io';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../../data/models/imovel_model.dart';

class ImovelRepository {
  final ApiClient _apiClient = ApiClient();

  static const Map<String, String> _filterKeyMap = {
    'valorMin': 'valor_venal_min',
    'valorMax': 'valor_venal_max',
    'metragemMin': 'metragem_min',
    'metragemMax': 'metragem_max',
    'numQuartos': 'n_quartos',
    'numReformas': 'n_reformas',
    'possuiGaragem': 'possui_garagem',
    'mobiliado': 'mobiliado',
    'proprietarioCpf': 'cpf',
    'matricula': 'matricula',
    'tipo': 'tipo',
    'finalidade': 'finalidade',
    'comodidades': 'comodidade',
    'bairro': 'bairro',
    'cidade': 'cidade',
    'cep': 'cep',
    'logradouro': 'logradouro',
  };

  Future<List<ImovelModel>> filtrarImoveis(Map<String, dynamic> filters) async {
    final Map<String, dynamic> queryParams = {};

    filters.forEach((key, value) {
      if (value != null) {
        if (value is String && value.isEmpty) return;

        final backendKey = _filterKeyMap[key] ?? key;

        if (key == 'comodidades' && value is Map) {
          final activeAmenities = (value as Map<String, bool>)
              .entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .join(',');

          if (activeAmenities.isNotEmpty) {
            queryParams[backendKey] = activeAmenities;
          }
        } else if (value is bool) {
          if (value == true) queryParams[backendKey] = 'true';
        } else {
          queryParams[backendKey] = value.toString();
        }
      }
    });

    final responseData = await _apiClient.get(
      Endpoints.imoveisFilters,
      queryParams: queryParams,
      requireAuth: false,
    );

    if (responseData is List) {
      return responseData
          .map((json) => ImovelModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // Caso a API retorne algo que não é uma lista
      return [];
    }
  }

  Future<Map<String, dynamic>> registerImovel(
      Map<String, dynamic> imovelData) async {
    final responseData = await _apiClient.post(
      Endpoints.imoveisRegister,
      imovelData,
      requireAuth: true,
    );
    return responseData;
  }

  Future<void> updateImovel(ImovelModel imovel) async {
    try {
      await _apiClient.put(
        Endpoints.imoveisUpdate,
        imovel.toJson(),
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao atualizar imóvel: $e");
    }
  }

  Future<Map<String, dynamic>> uploadImovelFotos(
      String matricula, List<File> fotos) async {
    final responseData = await _apiClient.uploadMultipleFiles(
      Endpoints.imoveisUploadFotos,
      'fotos',
      matricula,
      fotos,
      requireAuth: true,
    );

    return responseData;
  }
}
