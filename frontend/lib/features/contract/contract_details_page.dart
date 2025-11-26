import 'package:aura_frontend/data/models/contrato_model.dart';
import 'package:aura_frontend/features/pagamentos/pagamentos_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContractDetailsPage extends StatelessWidget {
  final ContratoModel contrato;

  const ContractDetailsPage({super.key, required this.contrato});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'vigente':
        return Colors.green;
      case 'pendente':
        return Colors.amber;
      case 'em análise':
        return Colors.blueAccent;
      case 'encerrado':
        return Colors.grey;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              'Detalhes do Contrato',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 0.0,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Código: ${contrato.codigo}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                _statusColor(contrato.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            contrato.status,
                            style: TextStyle(
                              color: _statusColor(contrato.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Informações Gerais",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _infoTile(
                    context,
                    title: "Tipo do Contrato",
                    value: contrato.tipo,
                    icon: contrato.tipo.toLowerCase() == 'venda'
                        ? CupertinoIcons.cart_fill
                        : CupertinoIcons.house_fill,
                  ),
                  const SizedBox(height: 10),
                  _infoTile(
                    context,
                    title: "Valor",
                    value: "R\$ ${contrato.valor}",
                    icon: CupertinoIcons.money_dollar_circle_fill,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Partes Envolvidas",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _infoTile(
                    context,
                    title: "Proprietário",
                    value: contrato.cpfProprietario.toString(),
                    icon: CupertinoIcons.person_crop_circle,
                  ),
                  const SizedBox(height: 10),
                  _infoTile(
                    context,
                    title: "Corretor",
                    value: contrato.cpfCorretor.toString(),
                    icon: CupertinoIcons.person_2_square_stack,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
