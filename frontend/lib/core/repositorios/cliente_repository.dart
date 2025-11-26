import 'package:aura_frontend/core/api/api_client.dart';
import 'package:aura_frontend/core/api/endpoints.dart';

class ClienteRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> cadastrarCliente({
    required String cpf,
    required String prenome,
    required String sobrenome,
    required DateTime dataNascimento,
    required String email,
    required String telefones,
    required bool isProprietario,
    required bool isAdquirente,
    int? pontuacaoCredito,
  }) async {
    final String dataNascFormatada =
        dataNascimento.toIso8601String().split('T').first;

    final Map<String, dynamic> body = {
      "cpf": cpf,
      "prenome": prenome,
      "sobrenome": sobrenome,
      "data_nasc": dataNascFormatada,
      "email": email,
      "telefones": telefones,
      "proprietario": isProprietario,
      "adquirente": isAdquirente,
      "pontuacao_credito": pontuacaoCredito
    };

    try {
      await _apiClient.post(
        Endpoints.usuarioCadastroCliente,
        body,
        requireAuth: true,
      );
    } catch (e) {
      throw Exception("Falha ao cadastrar cliente: $e");
    }
  }
}
