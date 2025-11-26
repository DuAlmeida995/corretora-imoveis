import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

import 'package:aura_frontend/core/repositorios/contrato_repository.dart';
import 'package:aura_frontend/data/models/contrato_model.dart';

import 'package:flutter_masked_text2/flutter_masked_text2.dart';

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required ThemeData theme,
  required Color fieldColor,
  required Color primaryColor,
  Widget? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        if (suffixIcon != null) suffixIcon,
      ],
    ),
  );
}

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, top: 24.0, left: 4.0),
    child: Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
        fontSize: 14,
      ),
    ),
  );
}

Widget _buildPickerSelector({
  required ThemeData theme,
  required String title,
  required String value,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = theme.brightness == Brightness.dark;
  final primaryColor = isDark ? Colors.white : Colors.black;
  final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

  return GestureDetector(
    onTap: onTap,
    child: Container(
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
              style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(width: 8),
          Icon(CupertinoIcons.chevron_down, color: primaryColor, size: 16),
        ],
      ),
    ),
  );
}

// ====================================================================
// PÁGINA PRINCIPAL
// ====================================================================

class ContractRegistrationPage extends StatefulWidget {
  const ContractRegistrationPage({super.key});

  @override
  State<ContractRegistrationPage> createState() =>
      _ContractRegistrationPageState();
}

class _ContractRegistrationPageState extends State<ContractRegistrationPage> {
  final ContratosRepository _contratosRepository = ContratosRepository();
  final AuthenticationRepository _authRepository = AuthenticationRepository();

  bool _isLoading = false;
  String _cpfCorretorLogado = "";

  final TextEditingController _matriculaImovelController =
      TextEditingController();
  final TextEditingController _cpfAdquirenteController =
      TextEditingController();
  final TextEditingController _cpfProprietarioController =
      TextEditingController();

  final MoneyMaskedTextController _valorController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
    precision: 2,
  );

  final TextEditingController _statusController =
      TextEditingController(text: 'Ativo');

  String _tipoContrato = 'Aluguel';
  final List<String> _tiposContratoDisponiveis = ['Aluguel', 'Venda'];

  DateTime? _dataInicio;
  DateTime? _dataFim;

  final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final profile = await _authRepository.loadProfile();
      if (profile != null && mounted) {
        setState(() {
          _cpfCorretorLogado = profile.cpf;
        });
      }
    } catch (e) {
      print("Erro ao carregar perfil: $e");
    }
  }

  void _handleContractRegistration() async {
    if (_isLoading) return;

    if (_matriculaImovelController.text.isEmpty ||
        _cpfAdquirenteController.text.isEmpty ||
        _cpfProprietarioController.text.isEmpty ||
        _valorController.numberValue <= 0) {
      _showAlert("Dados Incompletos", "Preencha todos os campos obrigatórios.");
      return;
    }

    if (_dataInicio == null || _dataFim == null) {
      _showAlert("Datas", "Por favor, selecione as datas de início e fim.");
      return;
    }

    setState(() => _isLoading = true);

    final cpfAdqLimpo =
        _cpfAdquirenteController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cpfPropLimpo =
        _cpfProprietarioController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final novoContrato = ContratoModel(
      codigo: 0,
      valor: _valorController.numberValue,
      status: _statusController.text,
      tipo: _tipoContrato,
      dataInicio: _dataInicio!,
      dataFim: _dataFim!,
      matriculaImovel: _matriculaImovelController.text.trim(),
      cpfAdquirente: cpfAdqLimpo,
      cpfProprietario: cpfPropLimpo,
      cpfCorretor: _cpfCorretorLogado,
    );
    try {
      final novoCodigo =
          await _contratosRepository.cadastrarContrato(novoContrato);

      if (mounted) {
        setState(() => _isLoading = false);

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Sucesso"),
            content:
                Text("Contrato ${novoCodigo ?? 'registrado'} com sucesso!"),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMsg = e.toString().replaceAll("Exception:", "").trim();
        _showAlert("Erro no Cadastro", errorMsg);
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
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showContractTypePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(top: 10, right: 16),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text("Pronto",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                      initialItem:
                          _tiposContratoDisponiveis.indexOf(_tipoContrato)),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _tipoContrato = _tiposContratoDisponiveis[index];
                    });
                  },
                  children: _tiposContratoDisponiveis
                      .map((t) => Center(child: Text(t)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker(bool isInicio) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 280,
        color: CupertinoColors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(top: 10, right: 16),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text("Pronto",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: isInicio
                      ? (_dataInicio ?? DateTime.now())
                      : (_dataFim ?? DateTime.now()),
                  onDateTimeChanged: (val) {
                    setState(() {
                      if (isInicio)
                        _dataInicio = val;
                      else
                        _dataFim = val;
                    });
                  },
                ),
              ),
            ],
          ),
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
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    String dataInicioTxt = _dataInicio == null
        ? "Selecionar"
        : DateFormat('dd/MM/yyyy').format(_dataInicio!);
    String dataFimTxt = _dataFim == null
        ? "Selecionar"
        : DateFormat('dd/MM/yyyy').format(_dataFim!);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Novo Contrato",
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
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.back, color: primaryColor),
            ),
            trailing: _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _handleContractRegistration,
                    child: const Text("Salvar",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, "Classificação"),
                  const SizedBox(height: 16),
                  _buildPickerSelector(
                    theme: theme,
                    title: "Tipo",
                    value: _tipoContrato,
                    icon: CupertinoIcons.doc_text,
                    onTap: _showContractTypePicker,
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader(theme, "Financeiro e Status"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _valorController,
                    hintText: "Valor (R\$)",
                    icon: CupertinoIcons.money_dollar_circle,
                    keyboardType: TextInputType.number,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _statusController,
                    hintText: "Status (ex: Ativo)",
                    icon: CupertinoIcons.info,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader(theme, "Partes Envolvidas"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _matriculaImovelController,
                    hintText: "Matrícula do Imóvel",
                    icon: CupertinoIcons.building_2_fill,
                    keyboardType: TextInputType.number,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cpfProprietarioController,
                    hintText: "CPF do Proprietário",
                    icon: CupertinoIcons.person_crop_circle,
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfFormatter],
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cpfAdquirenteController,
                    hintText: "CPF do Adquirente",
                    icon: CupertinoIcons.person_2_fill,
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfFormatter],
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader(theme, "Vigência"),
                  const SizedBox(height: 16),
                  _buildPickerSelector(
                    theme: theme,
                    title: "Início",
                    value: dataInicioTxt,
                    icon: CupertinoIcons.calendar_today,
                    onTap: () => _showDatePicker(true),
                  ),
                  const SizedBox(height: 12),
                  _buildPickerSelector(
                    theme: theme,
                    title: "Fim / Previsão",
                    value: dataFimTxt,
                    icon: CupertinoIcons.calendar_badge_plus,
                    onTap: () => _showDatePicker(false),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
