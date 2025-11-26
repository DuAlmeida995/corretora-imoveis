import 'dart:io';

import 'package:aura_frontend/features/pagamentos/pagamentos_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:aura_frontend/core/repositorios/pagamentos_repository.dart';
import 'package:aura_frontend/data/models/pagamento_model.dart';
import 'package:aura_frontend/routes/app_routes.dart';

// ----------------------------------------------------------------------
//                       PÁGINA PRINCIPAL
// ----------------------------------------------------------------------

class PagamentosListPage extends StatefulWidget {
  const PagamentosListPage({super.key});

  @override
  State<PagamentosListPage> createState() => _PagamentosListPageState();
}

class _PagamentosListPageState extends State<PagamentosListPage> {
  final PagamentosRepository _repository = PagamentosRepository();

  // Estado
  List<PagamentoModel> _pagamentos = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Controlador de Busca (Matrícula)
  final TextEditingController _matriculaSearchController =
      TextEditingController();

  // Formatadores
  final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _matriculaSearchController.dispose();
    super.dispose();
  }

  // --- AÇÕES ---

  // Busca pagamentos pelo imóvel
  Future<void> _searchPagamentos() async {
    final matricula = _matriculaSearchController.text.trim();
    if (matricula.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final resultados = await _repository.getExtratoImovel(matricula);

      if (mounted) {
        setState(() {
          _pagamentos = resultados;
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasSearched = true;
          _pagamentos = [];
        });
        _showAlert("Erro", "Não foi possível buscar os pagamentos: $e");
      }
    }
  }

  void _navigateToCadastro(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.pagamentosCadastro);
  }

  void _showAlert(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _exportarExtratoPdf() async {
    if (_pagamentos.isEmpty) {
      _showAlert(
          "Atenção", "Não há dados para exportar. Faça uma busca primeiro.");
      return;
    }

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CupertinoActivityIndicator(radius: 15)),
    );

    try {
      final pdf = pw.Document();
      final matricula = _matriculaSearchController.text;
      final dataEmissao = dateFormat.format(DateTime.now());

      double totalPago = 0;
      double totalPendente = 0;
      for (var p in _pagamentos) {
        if (p.status.toLowerCase() == 'pago')
          totalPago += p.valor;
        else
          totalPendente += p.valor;
      }

      final tableData = _pagamentos
          .map((p) => [
                dateFormat.format(p.dataVencimento),
                p.numeroPagamento.toString(),
                p.tipo.toUpperCase(),
                p.status.toUpperCase(),
                p.formaPagamento,
                currencyFormat.format(p.valor),
              ])
          .toList();

      tableData.insert(
          0, ['Vencimento', 'Parc.', 'Tipo', 'Status', 'Forma', 'Valor']);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("AURA CORRETORA",
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Extrato Financeiro",
                      style: const pw.TextStyle(
                          fontSize: 16, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Informações do Imóvel
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Imóvel (Matrícula): $matricula",
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("Emissão: $dataEmissao",
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                            "Total Pago: ${currencyFormat.format(totalPago)}",
                            style: pw.TextStyle(
                                color: PdfColors.green700,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            "Pendente: ${currencyFormat.format(totalPendente)}",
                            style: pw.TextStyle(color: PdfColors.red700)),
                      ]),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headers: tableData[0],
              data: tableData.sublist(1),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
              rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                5: pw.Alignment.centerRight,
              },
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerCellDecoration:
                  const pw.BoxDecoration(color: PdfColors.black),
            ),

            pw.SizedBox(height: 30),
            pw.Footer(
              leading: pw.Text("Aura Corretora Imobiliária",
                  style:
                      const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              trailing: pw.Text("Página 1",
                  style:
                      const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          "extrato_${matricula}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        Navigator.pop(context);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showAlert("Erro no PDF", "Falha ao gerar arquivo: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Financeiro",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        "Extratos por Imóvel",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_hasSearched && _pagamentos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(CupertinoIcons.printer,
                                  size: 20, color: Colors.black),
                              onPressed: _exportarExtratoPdf,
                              tooltip: "Exportar PDF",
                            ),
                          ),
                        ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        color: isDark ? Colors.grey.shade800 : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.pagamentosCadastro),
                        child: const Icon(CupertinoIcons.add,
                            size: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- BARRA DE BUSCA (Matrícula) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.search,
                              color: Colors.grey.shade500),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _matriculaSearchController,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: primaryColor),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "Buscar por Matrícula...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              onSubmitted: (_) => _searchPagamentos(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon:
                          Icon(CupertinoIcons.arrow_right, color: primaryColor),
                      onPressed: _searchPagamentos,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _buildContentState(primaryColor, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // Gerencia o que mostrar (Loading, Vazio, Lista)
  Widget _buildContentState(Color primaryColor, bool isDark) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.doc_text_search,
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Digite a matrícula para ver o extrato.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_pagamentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.clear_circled,
                size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Nenhum pagamento encontrado para este imóvel.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // LISTA DE PAGAMENTOS
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _pagamentos.length,
      itemBuilder: (context, index) {
        final pagamento = _pagamentos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildPaymentCard(pagamento, primaryColor, isDark),
        );
      },
    );
  }

  // --- CARD DE PAGAMENTO ---
  Widget _buildPaymentCard(PagamentoModel p, Color primaryColor, bool isDark) {
    Color statusColor;
    IconData statusIcon;

    switch (p.status.toLowerCase()) {
      case 'pago':
        statusColor = CupertinoColors.activeGreen;
        statusIcon = CupertinoIcons.checkmark_circle_fill;
        break;
      case 'atrasado':
        statusColor = CupertinoColors.systemRed;
        statusIcon = CupertinoIcons.exclamationmark_circle_fill;
        break;
      case 'pendente':
        statusColor = CupertinoColors.systemOrange;
        statusIcon = CupertinoIcons.clock_fill;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = CupertinoIcons.question_circle_fill;
    }

    return GestureDetector(
      onTap: () async {
        final bool? result = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PagamentoDetailsPage(pagamento: p),
          ),
        );

        if (result == true) {
          _searchPagamentos();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border:
              Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // Linha Superior: Tipo e Valor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          p.tipo.toLowerCase() == 'multa'
                              ? CupertinoIcons.exclamationmark_triangle
                              : CupertinoIcons.house_fill,
                          size: 18,
                          color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.tipo.toUpperCase(), // "ALUGUEL", "MULTA"
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5),
                        ),
                        Text(
                          "Parcela ${p.numeroPagamento}",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(p.valor),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),

            // Linha Inferior: Datas e Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Vencimento",
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(p.dataVencimento),
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                // Badge de Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        p.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
