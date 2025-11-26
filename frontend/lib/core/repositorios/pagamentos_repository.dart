import 'package:aura_frontend/core/api/api_client.dart';
import 'package:aura_frontend/core/api/endpoints.dart';
import '../../data/models/pagamento_model.dart';

class PagamentosRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> cadastrarPagamento(PagamentoModel pagamento) async {
    try {
      await _apiClient.post(
        Endpoints.pagamentosCadastro,
        pagamento.toJson(),
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao registrar pagamento: $e");
    }
  }

  Future<List<PagamentoModel>> getExtratoImovel(String matricula) async {
    final response = await _apiClient.get(
      Endpoints.pagamentosExtratoImovel,
      queryParams: {'matricula': matricula},
      requireAuth: true,
    );

    if (response is List) {
      return response
          .map((json) => PagamentoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<PagamentoModel>> getExtratoAdquirente(
      String cpfAdquirente) async {
    final response = await _apiClient.get(
      Endpoints.pagamentosExtratoAdquirente,
      queryParams: {'cpf': cpfAdquirente},
      requireAuth: true,
    );

    if (response is List) {
      return response
          .map((json) => PagamentoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> atualizarStatus(
      String codigoContrato, int numeroPagamento, String novoStatus) async {
    try {
      await _apiClient.put(
        Endpoints.pagamentosAtualizaStatus,
        {
          "codigo_contrato": codigoContrato,
          "n_pagamento": numeroPagamento,
          "status": novoStatus,
        },
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao atualizar status: $e");
    }
  }
}
