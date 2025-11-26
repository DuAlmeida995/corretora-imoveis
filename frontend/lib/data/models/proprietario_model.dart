import 'package:aura_frontend/data/models/imovel_model.dart';

class ProprietarioModel {
  final String nome;
  final String sobrenome;
  final String cpf;
  final String telefone;
  final String email;
  final List<ImovelModel> imoveis;
  final String dataNascimento;

  const ProprietarioModel({
    required this.nome,
    required this.sobrenome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.imoveis,
    required this.dataNascimento,
  });
}
