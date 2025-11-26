import 'package:aura_frontend/core/repositorios/contrato_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aura_frontend/data/models/historico_pessoas_model.dart';

class ImovelHistoryPage extends StatefulWidget {
  final String matricula;

  const ImovelHistoryPage({super.key, required this.matricula});

  @override
  State<ImovelHistoryPage> createState() => _ImovelHistoryPageState();
}

class _ImovelHistoryPageState extends State<ImovelHistoryPage> {
  final ContratosRepository _repository = ContratosRepository();

  List<HistoricoPessoasModel> _historico = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final data =
          await _repository.getHistoricoPessoasImovel(widget.matricula);
      if (mounted) {
        setState(() {
          _historico = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Não foi possível carregar o histórico.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = isDark ? Colors.white10 : Colors.grey.shade50;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // HEADER ELEGANTE
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Histórico de Ocupação",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: backgroundColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.back, color: primaryColor),
            ),
          ),

          // CONTEÚDO
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                  child: Text(_errorMessage!,
                      style: TextStyle(color: secondaryTextColor))),
            )
          else if (_historico.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.doc_text_search,
                        size: 48, color: secondaryTextColor),
                    const SizedBox(height: 16),
                    Text("Nenhum contrato registrado para este imóvel.",
                        style: TextStyle(color: secondaryTextColor)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _historico[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildHistoryCard(item, primaryColor,
                          secondaryTextColor, cardColor, borderColor),
                    );
                  },
                  childCount: _historico.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET DO CARD DE HISTÓRICO ---
  Widget _buildHistoryCard(
    HistoricoPessoasModel item,
    Color primaryColor,
    Color secondaryColor,
    Color cardColor,
    Color borderColor,
  ) {
    final bool isVenda = item.tipo.toLowerCase() == 'venda';
    final IconData typeIcon =
        isVenda ? CupertinoIcons.money_dollar_circle : CupertinoIcons.doc_text;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Card (Tipo e Status)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                "${item.tipo} #${item.codigoContrato}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Linha do Proprietário
          _buildPersonRow(
            role: "PROPRIETÁRIO",
            name: item.proprietarioCompleto,
            icon: CupertinoIcons.person_crop_circle_badge_checkmark,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),

          // Linha Conectora (Visual de Timeline)
          Padding(
            padding: const EdgeInsets.only(left: 23, top: 4, bottom: 4),
            child: Container(
              width: 2,
              height: 14,
              color: borderColor,
            ),
          ),

          // Linha do Adquirente/Inquilino
          _buildPersonRow(
            role: isVenda ? "COMPRADOR" : "INQUILINO",
            name: item.nomeAdquirente.isNotEmpty
                ? item.adquirenteCompleto
                : "Não informado",
            icon: CupertinoIcons.person_2,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonRow({
    required String role,
    required String name,
    required IconData icon,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 48, color: primaryColor.withOpacity(0.8)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
