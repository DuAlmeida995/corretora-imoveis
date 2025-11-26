import 'package:aura_frontend/core/repositorios/cliente_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, top: 24.0, left: 4.0),
    child: Text(
      title.toUpperCase(),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required ThemeData theme,
  required Color fieldColor,
  required Color primaryColor,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: fieldColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
              ),
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
  required bool isDark,
  IconData? icon,
}) {
  final primaryColor = isDark ? Colors.white : Colors.black;
  final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 16, color: primaryColor)),
          ),
          Text(value,
              style: const TextStyle(
                  color: CupertinoColors.black, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.chevron_right,
              color: Colors.grey, size: 14),
        ],
      ),
    ),
  );
}

Widget _buildSwitchTile({
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
  required bool isDark,
}) {
  final primaryColor = isDark ? Colors.white : Colors.black;
  final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: fieldColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryColor)),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: primaryColor,
        ),
      ],
    ),
  );
}

class ClientRegistrationPage extends StatefulWidget {
  const ClientRegistrationPage({super.key});

  @override
  State<ClientRegistrationPage> createState() => _ClientRegistrationPageState();
}

class _ClientRegistrationPageState extends State<ClientRegistrationPage> {
  final ClienteRepository _repository = ClienteRepository();
  bool _isLoading = false;

  final TextEditingController _prenomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();

  DateTime _dataNascimento = DateTime(1990, 1, 1);
  bool _isProprietario = false;
  bool _isAdquirente = true;

  final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  final phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void dispose() {
    _prenomeController.dispose();
    _sobrenomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _handleRegistration() async {
    if (_prenomeController.text.isEmpty ||
        _sobrenomeController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telefoneController.text.isEmpty) {
      _showAlert("Dados Incompletos", "Preencha todos os campos obrigatórios.");
      return;
    }

    if (!_isProprietario && !_isAdquirente) {
      _showAlert("Tipo de Cliente",
          "Selecione ao menos um tipo (Proprietário ou Adquirente).");
      return;
    }

    setState(() => _isLoading = true);

    final cpfLimpo = cpfFormatter.getUnmaskedText();
    final telefoneLimpo = phoneFormatter.getUnmaskedText();
    final score = int.tryParse(_scoreController.text);

    try {
      await _repository.cadastrarCliente(
        cpf: cpfLimpo,
        prenome: _prenomeController.text.trim(),
        sobrenome: _sobrenomeController.text.trim(),
        dataNascimento: _dataNascimento,
        email: _emailController.text.trim(),
        telefones: telefoneLimpo,
        isProprietario: _isProprietario,
        isAdquirente: _isAdquirente,
        pontuacaoCredito: score,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text("Sucesso"),
            content: const Text("Cliente cadastrado com sucesso!"),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String msg = e.toString().replaceAll("Exception:", "").trim();
        _showAlert("Erro", msg);
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

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
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
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _dataNascimento,
                onDateTimeChanged: (val) =>
                    setState(() => _dataNascimento = val),
              ),
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
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    final dateStr = DateFormat('dd/MM/yyyy').format(_dataNascimento);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle:
                Text("Novo Cliente", style: TextStyle(color: primaryColor)),
            backgroundColor: backgroundColor,
            border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 0.0)),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            trailing: _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _handleRegistration,
                    child: const Text("Salvar",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, "Dados Pessoais"),
                  _buildTextField(
                      controller: _prenomeController,
                      hintText: "Nome",
                      icon: CupertinoIcons.person,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _sobrenomeController,
                      hintText: "Sobrenome",
                      icon: CupertinoIcons.person,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cpfController,
                    hintText: "CPF",
                    icon: CupertinoIcons.number,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfFormatter],
                  ),
                  const SizedBox(height: 12),
                  _buildSelectorTile(
                    label: "Nascimento",
                    value: dateStr,
                    onTap: _showDatePicker,
                    isDark: isDark,
                    icon: CupertinoIcons.calendar,
                  ),
                  _buildSectionHeader(theme, "Contato"),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "E-mail",
                    icon: CupertinoIcons.mail,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _telefoneController,
                    hintText: "Telefone",
                    icon: CupertinoIcons.phone,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneFormatter],
                  ),
                  _buildSectionHeader(theme, "Classificação"),
                  _buildSwitchTile(
                    title: "Proprietário",
                    value: _isProprietario,
                    onChanged: (v) => setState(() => _isProprietario = v),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    title: "Adquirente",
                    value: _isAdquirente,
                    onChanged: (v) => setState(() => _isAdquirente = v),
                    isDark: isDark,
                  ),
                  if (_isAdquirente) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _scoreController,
                      hintText: "Pontuação de Crédito (0-1000)",
                      icon: CupertinoIcons.chart_bar,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
