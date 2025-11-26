import 'package:aura_frontend/core/api/api_client.dart';
import 'package:aura_frontend/core/api/endpoints.dart';
import 'package:aura_frontend/data/models/historico_pessoas_model.dart';
import '../../data/models/contrato_model.dart';

class ContratosRepository {
  final ApiClient _apiClient = ApiClient();

  Future<int?> cadastrarContrato(ContratoModel contrato) async {
    final Map<String, dynamic> body = Map.from(contrato.toJson());
    body.remove('codigo');

    try {
      final response = await _apiClient.post(
        Endpoints.contratoCadastro,
        body,
        requireAuth: true,
      );

      if (response.containsKey('codigo')) {
        return response['codigo'] as int;
      }
      return null;
    } catch (e) {
      throw Exception("Falha ao criar contrato: $e");
    }
  }

  Future<void> deletarContrato(String codigo) async {
    try {
      await _apiClient.delete(
        Endpoints.contratoDeletar,
        queryParams: {'codigo': codigo},
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao deletar contrato: $e");
    }
  }

  Future<void> alterarStatus(String codigo, String novoStatus) async {
    try {
      await _apiClient.put(
        Endpoints.contratoAlterarStatus,
        {
          "codigo": codigo,
          "status": novoStatus,
        },
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao alterar status: $e");
    }
  }

  Future<List<ContratoModel>> getContratosGerais({int? limit}) async {
    final Map<String, dynamic> queryParams = {};
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    final response = await _apiClient.get(
      Endpoints.contratosList,
      queryParams: queryParams,
      requireAuth: true,
    );
    if (response is List) {
      return response.map((j) => ContratoModel.fromJson(j)).toList();
    }
    return [];
  }

  /// Obtém os contadores para os Cards (Retorna um Map)
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiClient.get(
      Endpoints.contratosDashboard,
      requireAuth: true,
    );
    return response is Map<String, dynamic> ? response : {};
  }

  Future<List<HistoricoPessoasModel>> getHistoricoPessoasImovel(
      String matricula) async {
    try {
      final response = await _apiClient.get(
        Endpoints.contratoPessoasImovel,
        queryParams: {'matricula': matricula},
        requireAuth: true,
      );

      if (response is List) {
        return response
            .map((json) =>
                HistoricoPessoasModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception("Erro ao buscar histórico de pessoas: $e");
    }
  }
}
