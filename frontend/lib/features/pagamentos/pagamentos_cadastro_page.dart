import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:aura_frontend/core/repositorios/pagamentos_repository.dart';
import 'package:aura_frontend/data/models/pagamento_model.dart';

class PagamentoRegistrationPage extends StatefulWidget {
  const PagamentoRegistrationPage({super.key});

  @override
  State<PagamentoRegistrationPage> createState() =>
      _PagamentoRegistrationPageState();
}

class _PagamentoRegistrationPageState extends State<PagamentoRegistrationPage> {
  final PagamentosRepository _repository = PagamentosRepository();
  bool _isLoading = false;

  final TextEditingController _codigoContratoController =
      TextEditingController();
  final MoneyMaskedTextController _valorController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
    precision: 2,
  );

  int _numeroPagamento = 1;
  DateTime _dataVencimento = DateTime.now();
  DateTime _dataPagamento = DateTime.now();

  final List<String> _tiposPagamento = [
    'Aluguel',
    'Multa',
    'Taxa Extra',
    'Seguro'
  ];
  String _tipoSelected = 'Aluguel';
  final List<String> _formasPagamento = [
    'Boleto',
    'Pix',
    'Transferência',
    'Dinheiro'
  ];
  String _formaSelected = 'Pix';
  final List<String> _statusPagamento = [
    'Pago',
    'Pendente',
    'Atrasado',
    'Cancelado'
  ];
  String _statusSelected = 'Pago';

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color:
              isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType type = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white10 : CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: type,
              style: TextStyle(color: primaryColor, fontSize: 17),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isDark ? Colors.white10 : CupertinoColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 17, color: primaryColor)),
            ),
            Text(value,
                style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 17)),
            const SizedBox(width: 6),
            const Icon(CupertinoIcons.chevron_right,
                color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white10 : CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Nº Parcela",
              style: TextStyle(fontSize: 17, color: primaryColor)),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.minus_circle_fill,
                    color: Colors.grey.shade500, size: 28),
                onPressed: () => setState(() {
                  if (_numeroPagamento > 1) _numeroPagamento--;
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('$_numeroPagamento',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.plus_circle_fill,
                    color: primaryColor, size: 28),
                onPressed: () => setState(() => _numeroPagamento++),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- LÓGICA DE PICKERS ---

  void _showDatePicker(bool isVencimento) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  child: const Text("Pronto"),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime:
                      isVencimento ? _dataVencimento : _dataPagamento,
                  onDateTimeChanged: (val) => setState(() {
                    if (isVencimento)
                      _dataVencimento = val;
                    else
                      _dataPagamento = val;
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showListPicker(List<String> items, Function(String) onSelected) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 32,
            onSelectedItemChanged: (index) => onSelected(items[index]),
            children: items.map((e) => Center(child: Text(e))).toList(),
          ),
        ),
      ),
    );
  }

  void _savePagamento() async {
    if (_codigoContratoController.text.isEmpty ||
        _valorController.numberValue <= 0) {
      _showAlert("Dados Incompletos",
          "Informe o código do contrato e um valor válido.");
      return;
    }
    setState(() => _isLoading = true);

    final novoPagamento = PagamentoModel(
      codigoContrato: _codigoContratoController.text.trim(),
      numeroPagamento: _numeroPagamento,
      valor: _valorController.numberValue,
      dataVencimento: _dataVencimento,
      dataPagamento: _dataPagamento,
      status: _statusSelected,
      formaPagamento: _formaSelected,
      tipo: _tipoSelected,
    );

    try {
      await _repository.cadastrarPagamento(novoPagamento);
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Pagamento registrado!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showAlert("Erro", e.toString());
      }
    }
  }

  void _showAlert(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
              child: const Text("OK"), onPressed: () => Navigator.pop(ctx))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle:
                Text("Novo Pagamento", style: TextStyle(color: primaryColor)),
            backgroundColor: backgroundColor,
            border: null,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            trailing: _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _savePagamento,
                    child: const Text("Salvar",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Vínculo"),
                _buildTextField(
                  controller: _codigoContratoController,
                  hint: "Código do Contrato",
                  icon: CupertinoIcons.doc_text,
                ),
                _buildSectionHeader("Valores e Prazos"),
                _buildTextField(
                  controller: _valorController,
                  hint: "Valor (R\$)",
                  icon: CupertinoIcons.money_dollar,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildStepper(),
                const SizedBox(height: 12),
                _buildSelectorTile(
                  label: "Vencimento",
                  value: DateFormat('dd/MM/yyyy').format(_dataVencimento),
                  icon: CupertinoIcons.calendar_today,
                  onTap: () => _showDatePicker(true),
                ),
                _buildSelectorTile(
                  label: "Data Pagamento",
                  value: DateFormat('dd/MM/yyyy').format(_dataPagamento),
                  icon: CupertinoIcons.check_mark_circled,
                  onTap: () => _showDatePicker(false),
                ),
                _buildSectionHeader("Classificação"),
                _buildSelectorTile(
                  label: "Tipo",
                  value: _tipoSelected,
                  icon: CupertinoIcons.tag,
                  onTap: () => _showListPicker(_tiposPagamento,
                      (val) => setState(() => _tipoSelected = val)),
                ),
                _buildSelectorTile(
                  label: "Forma",
                  value: _formaSelected,
                  icon: CupertinoIcons.creditcard,
                  onTap: () => _showListPicker(_formasPagamento,
                      (val) => setState(() => _formaSelected = val)),
                ),
                _buildSelectorTile(
                  label: "Status",
                  value: _statusSelected,
                  icon: CupertinoIcons.info_circle,
                  onTap: () => _showListPicker(_statusPagamento,
                      (val) => setState(() => _statusSelected = val)),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
