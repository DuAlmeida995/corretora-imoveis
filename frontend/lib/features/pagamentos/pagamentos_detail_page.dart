import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aura_frontend/core/repositorios/pagamentos_repository.dart';
import 'package:aura_frontend/data/models/pagamento_model.dart';

class PagamentoDetailsPage extends StatefulWidget {
  final PagamentoModel pagamento;

  const PagamentoDetailsPage({super.key, required this.pagamento});

  @override
  State<PagamentoDetailsPage> createState() => _PagamentoDetailsPageState();
}

class _PagamentoDetailsPageState extends State<PagamentoDetailsPage> {
  final PagamentosRepository _repository = PagamentosRepository();
  bool _isLoading = false;

  // Estado do Status
  late String _currentStatus;
  final List<String> _statusOptions = [
    'Pago',
    'Pendente',
    'Atrasado',
    'Cancelado'
  ];

  // Formatadores
  final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.pagamento.status;
  }

  // --- AÇÃO DE SALVAR ---
  void _updateStatus() async {
    setState(() => _isLoading = true);

    try {
      await _repository.atualizarStatus(
        widget.pagamento.codigoContrato,
        widget.pagamento.numeroPagamento,
        _currentStatus,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text("Sucesso"),
            content: const Text("Status atualizado com sucesso."),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showAlert("Erro", "Falha ao atualizar: $e");
      }
    }
  }

  void _showAlert(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
              child: const Text("OK"), onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  void _showStatusPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: CupertinoButton(
                  child: const Text("Pronto"),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                      initialItem: _statusOptions.indexOf(_currentStatus) != -1
                          ? _statusOptions.indexOf(_currentStatus)
                          : 0),
                  onSelectedItemChanged: (index) =>
                      setState(() => _currentStatus = _statusOptions[index]),
                  children: _statusOptions
                      .map((e) => Center(child: Text(e)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          Text(value,
              style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ??
                      (theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black))),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _showStatusPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Status Atual",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(
                  _currentStatus.toUpperCase(),
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.chevron_down,
                    size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text("Detalhes", style: TextStyle(color: primaryColor)),
            backgroundColor: backgroundColor,
            border: null,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Valor em Destaque
                  Center(
                    child: Column(
                      children: [
                        Text("Valor da Parcela",
                            style: TextStyle(color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(widget.pagamento.valor),
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Informações Estáticas
                  Text("INFORMAÇÕES",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      theme, "Contrato", "#${widget.pagamento.codigoContrato}"),
                  const Divider(height: 1),
                  _buildInfoRow(
                      theme, "Parcela", "${widget.pagamento.numeroPagamento}"),
                  const Divider(height: 1),
                  _buildInfoRow(
                      theme, "Tipo", widget.pagamento.tipo.toUpperCase()),
                  const Divider(height: 1),
                  _buildInfoRow(theme, "Vencimento",
                      dateFormat.format(widget.pagamento.dataVencimento)),
                  const Divider(height: 1),
                  _buildInfoRow(theme, "Pagamento",
                      dateFormat.format(widget.pagamento.dataPagamento)),

                  const SizedBox(height: 40),

                  // Seletor de Status
                  Text("GERENCIAMENTO",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  _buildStatusSelector(theme, isDark),

                  const SizedBox(height: 40),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _isLoading ? null : _updateStatus,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white)
                          : Text(
                              "Atualizar Status",
                              style: TextStyle(
                                  color: backgroundColor,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
