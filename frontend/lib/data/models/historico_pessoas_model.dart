class HistoricoPessoasModel {
  final int codigoContrato;
  final String tipo; // Aluguel/Venda
  final String status;
  final String nomeProprietario;
  final String sobrenomeProprietario;
  final String nomeAdquirente;
  final String sobrenomeAdquirente;

  String get proprietarioCompleto => "$nomeProprietario $sobrenomeProprietario";
  String get adquirenteCompleto => "$nomeAdquirente $sobrenomeAdquirente";

  const HistoricoPessoasModel({
    required this.codigoContrato,
    required this.tipo,
    required this.status,
    required this.nomeProprietario,
    required this.sobrenomeProprietario,
    required this.nomeAdquirente,
    required this.sobrenomeAdquirente,
  });

  factory HistoricoPessoasModel.fromJson(Map<String, dynamic> json) {
    return HistoricoPessoasModel(
      codigoContrato: json['codigo'] is int
          ? json['codigo']
          : int.tryParse(json['codigo'].toString()) ?? 0,
      tipo: json['tipo'] ?? 'Indefinido',
      status: json['status'] ?? 'Indefinido',
      nomeProprietario: json['proprietario_nome'] ?? '',
      sobrenomeProprietario: json['proprietario_sobrenome'] ?? '',
      nomeAdquirente: json['adquirente_nome'] ?? '',
      sobrenomeAdquirente: json['adquirente_sobrenome'] ?? '',
    );
  }
}
