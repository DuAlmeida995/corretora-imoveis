import 'dart:io';

class ContratoModel {
  final int codigo;
  final double valor;
  final String status;
  final String tipo;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String matriculaImovel;
  final String cpfProprietario;
  final String cpfCorretor;
  final String cpfAdquirente;

  const ContratoModel({
    required this.codigo,
    required this.valor,
    required this.status,
    required this.dataInicio,
    required this.dataFim,
    required this.tipo,
    required this.matriculaImovel,
    required this.cpfProprietario,
    required this.cpfCorretor,
    required this.cpfAdquirente,
  });

  factory ContratoModel.fromJson(Map<String, dynamic> json) {
    return ContratoModel(
      codigo: json['codigo'] is int
          ? json['codigo']
          : int.tryParse(json['codigo']?.toString() ?? '0') ?? 0,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Ativo',
      dataInicio: _parseDate(json['data_inicio']),
      dataFim: _parseDate(json['data_fim']),
      tipo: json['tipo'] ?? 'Aluguel',
      matriculaImovel: json['matricula']?.toString() ??
          json['matricula_imovel']?.toString() ??
          '',
      cpfProprietario: json['cpf_prop'] ?? '',
      cpfCorretor: json['cpf_corretor'] ?? '',
      cpfAdquirente: json['cpf_adquirente'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'valor': valor,
      'status': status,
      // Envia no formato ISO (YYYY-MM-DD) que o banco espera no cadastro
      'data_inicio': dataInicio.toIso8601String().split('T').first,
      'data_fim': dataFim.toIso8601String().split('T').first,
      'tipo': tipo,
      'matricula_imovel': matriculaImovel,
      'cpf_prop': cpfProprietario,
      'cpf_corretor': cpfCorretor,
      'cpf_adquirente': cpfAdquirente
    };
  }

  // --- FUNÇÃO AUXILIAR PARA DATAS ---
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    final dateStr = dateValue.toString();
    if (dateStr.isEmpty) return DateTime.now();

    try {
      return HttpDate.parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print("Erro ao converter data: $dateStr - $e");
        return DateTime.now();
      }
    }
  }
}
