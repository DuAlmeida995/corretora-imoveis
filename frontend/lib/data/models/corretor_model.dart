import 'dart:io';

class CorretorModel {
  final String prenome;
  final String sobrenome;
  final String cpf;
  final String telefone;
  final String email;
  final String dataNascimento;
  final String creci;
  final String especialidade;
  final String regiaoAtuacao;
  final String? profileImageUrl;

  const CorretorModel(
      {required this.prenome,
      required this.sobrenome,
      required this.cpf,
      required this.telefone,
      required this.email,
      required this.dataNascimento,
      required this.creci,
      required this.especialidade,
      required this.regiaoAtuacao,
      required this.profileImageUrl});

  factory CorretorModel.fromJson(Map<String, dynamic> json) {
    return CorretorModel(
        prenome: json['prenome'] ?? '',
        sobrenome: json['sobrenome'] ?? '',
        cpf: json['cpf'] ?? '',
        telefone: json['telefone'] ?? '',
        email: json['email'] ?? '',
        dataNascimento: json['dataNascimento'] ?? '',
        creci: json['creci'] ?? '',
        especialidade: json['especialidade'] ?? '',
        regiaoAtuacao: json['regiaoAtuacao'] ?? '',
        profileImageUrl: json['profile_image_url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'prenome': prenome,
      'sobrenome': sobrenome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'dataNascimento': dataNascimento,
      'creci': creci,
      'especialidade': especialidade,
      'regiaoAtuacao': regiaoAtuacao,
      'profile_image_url': profileImageUrl
    };
  }
}
