import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

import 'package:aura_frontend/core/repositorios/imovel_repository.dart';
import 'package:aura_frontend/data/models/imovel_model.dart';

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, top: 24.0, left: 4.0),
    child: Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
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
  Widget? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? suffixText,
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
              suffixText: suffixText,
              suffixStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.grey : Colors.grey.shade600),
            ),
          ),
        ),
        if (suffixIcon != null) suffixIcon,
      ],
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
              "$title: $value",
              style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            ),
          ),
          Icon(CupertinoIcons.chevron_down, color: primaryColor, size: 16),
        ],
      ),
    ),
  );
}

Widget _buildOptionTile({
  required ThemeData theme,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  final isDark = theme.brightness == Brightness.dark;
  final primaryColor = isDark ? Colors.white : Colors.black;

  return Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.white10 : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500, color: primaryColor)),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: primaryColor,
          trackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ],
    ),
  );
}

Widget _buildStepperField({
  required ThemeData theme,
  required String title,
  required int value,
  required ValueChanged<int> onChanged,
  int minimum = 0,
  IconData icon = CupertinoIcons.add_circled_solid,
}) {
  final primaryColor = theme.primaryColor;
  final isDark = theme.brightness == Brightness.dark;
  final boxColor = isDark ? Colors.white10 : Colors.grey.shade100;
  final textColor = isDark ? Colors.white : Colors.black;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: boxColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(title,
                    style:
                        theme.textTheme.bodyLarge?.copyWith(color: textColor),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: value > minimum ? () => onChanged(value - 1) : null,
              child: Icon(CupertinoIcons.minus_circle_fill,
                  size: 30,
                  color: value > minimum ? primaryColor : Colors.grey.shade400),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('$value',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: textColor)),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => onChanged(value + 1),
              child: Icon(CupertinoIcons.plus_circle_fill,
                  size: 30, color: primaryColor),
            ),
          ],
        ),
      ],
    ),
  );
}

// ====================================================================
// PÁGINA DE EDIÇÃO
// ====================================================================

class ImovelEditPage extends StatefulWidget {
  final ImovelModel imovel;

  const ImovelEditPage({super.key, required this.imovel});

  @override
  State<ImovelEditPage> createState() => _ImovelEditPageState();
}

class _ImovelEditPageState extends State<ImovelEditPage> {
  final ImovelRepository _repository = ImovelRepository();
  bool _isLoading = false;

  // Controladores
  late TextEditingController _logradouroController;
  late TextEditingController _numeroController;
  late TextEditingController _complementoController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeController;
  late TextEditingController _cepController;
  late TextEditingController _descricaoController;
  late TextEditingController _metragemController;
  late MoneyMaskedTextController _valorVenalController;

  // Estado
  int _numQuartos = 0;
  int _numReformas = 0;
  bool _possuiGaragem = false;
  bool _isMobiliado = false;

  String _tipoSelected = '';
  String _finalidadeSelected = '';

  final List<String> _tiposImovel = [
    'Apartamento',
    'Casa',
    'Cobertura',
    'Kitnet',
    'Sala Comercial',
    'Terreno',
    'Loft'
  ];
  final List<String> _finalidades = ['Residencial', 'Comercial'];

  final _cepFormatter = MaskTextInputFormatter(
      mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    final i = widget.imovel;

    _logradouroController = TextEditingController(text: i.logradouro);
    _numeroController = TextEditingController(text: i.numero);
    _complementoController = TextEditingController(text: i.complemento);
    _bairroController = TextEditingController(text: i.bairro);
    _cidadeController = TextEditingController(text: i.cidade);
    _cepController = TextEditingController(text: _cepFormatter.maskText(i.cep));
    _descricaoController = TextEditingController(text: i.descricao);

    _metragemController =
        TextEditingController(text: i.metragem.toString().replaceAll('.', ','));

    _valorVenalController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      precision: 2,
      initialValue: i.valorVenalRaw,
    );

    _numQuartos = i.numQuartos;
    _numReformas = i.numReformas;
    _possuiGaragem = i.possuiGaragem;
    _isMobiliado = i.eMobiliado;
    _tipoSelected = i.tipo.isNotEmpty ? i.tipo : _tiposImovel.first;
    _finalidadeSelected =
        i.finalidade.isNotEmpty ? i.finalidade : _finalidades.first;
  }

  @override
  void dispose() {
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _cepController.dispose();
    _descricaoController.dispose();
    _metragemController.dispose();
    _valorVenalController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    setState(() => _isLoading = true);

    final updatedImovel = ImovelModel(
      matricula: widget.imovel.matricula,
      cpfProprietario: widget.imovel.cpfProprietario,
      logradouro: _logradouroController.text,
      numero: _numeroController.text,
      complemento: _complementoController.text,
      bairro: _bairroController.text,
      cidade: _cidadeController.text,
      cep: _cepFormatter.getUnmaskedText(),
      descricao: _descricaoController.text,
      metragem:
          double.tryParse(_metragemController.text.replaceAll(',', '.')) ?? 0.0,
      valorVenalRaw: _valorVenalController.numberValue,
      numQuartos: _numQuartos,
      numReformas: _numReformas,
      tipo: _tipoSelected,
      finalidade: _finalidadeSelected,
      possuiGaragem: _possuiGaragem,
      eMobiliado: _isMobiliado,

      // Campos que não mudam nesta tela
      statusOcupacao: widget.imovel.statusOcupacao,
      imagens: widget.imovel.imagens,
      comodidades: widget.imovel.comodidades,
      contratos: widget.imovel.contratos,
    );

    try {
      await _repository.updateImovel(updatedImovel);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Imóvel atualizado com sucesso!"),
              backgroundColor: CupertinoColors.black),
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

  void _showPicker(List<String> items, Function(String) onSelected) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
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
                  itemExtent: 32,
                  onSelectedItemChanged: (index) => onSelected(items[index]),
                  children: items.map((e) => Center(child: Text(e))).toList(),
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle:
                Text("Editar Imóvel", style: TextStyle(color: primaryColor)),
            backgroundColor: backgroundColor,
            border: Border(
                bottom: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                    width: 0.0)),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            trailing: _isLoading
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _saveChanges,
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
                  _buildSectionHeader(theme, "Endereço"),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _cepController,
                      hintText: "CEP",
                      icon: CupertinoIcons.barcode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_cepFormatter],
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _logradouroController,
                      hintText: "Logradouro",
                      icon: CupertinoIcons.map_pin_ellipse,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _numeroController,
                      hintText: "Número",
                      icon: CupertinoIcons.number,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _complementoController,
                      hintText: "Complemento",
                      icon: CupertinoIcons.tag,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _bairroController,
                      hintText: "Bairro",
                      icon: CupertinoIcons.placemark_fill,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _cidadeController,
                      hintText: "Cidade",
                      icon: CupertinoIcons.building_2_fill,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 30),
                  _buildSectionHeader(theme, "Detalhes Financeiros"),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _valorVenalController,
                      hintText: "Valor Venal",
                      icon: CupertinoIcons.money_dollar_circle,
                      keyboardType: TextInputType.number,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _metragemController,
                      hintText: "Metragem",
                      icon: CupertinoIcons.resize,
                      keyboardType: TextInputType.number,
                      suffixText: " m²",
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _descricaoController,
                      hintText: "Descrição",
                      icon: CupertinoIcons.text_alignleft,
                      keyboardType: TextInputType.multiline,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 30),
                  _buildSectionHeader(theme, "Características"),
                  const SizedBox(height: 16),
                  _buildPickerSelector(
                    theme: theme,
                    title: "Tipo",
                    value: _tipoSelected,
                    icon: CupertinoIcons.house_alt_fill,
                    onTap: () => _showPicker(_tiposImovel,
                        (val) => setState(() => _tipoSelected = val)),
                  ),
                  const SizedBox(height: 12),
                  _buildPickerSelector(
                    theme: theme,
                    title: "Finalidade",
                    value: _finalidadeSelected,
                    icon: CupertinoIcons.flag_fill,
                    onTap: () => _showPicker(_finalidades,
                        (val) => setState(() => _finalidadeSelected = val)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStepperField(
                              theme: theme,
                              title: "Quartos",
                              value: _numQuartos,
                              onChanged: (val) =>
                                  setState(() => _numQuartos = val),
                              icon: CupertinoIcons.bed_double)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStepperField(
                              theme: theme,
                              title: "Reformas",
                              value: _numReformas,
                              onChanged: (val) =>
                                  setState(() => _numReformas = val),
                              icon: CupertinoIcons.hammer_fill)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                      theme: theme,
                      title: "Garagem",
                      value: _possuiGaragem,
                      onChanged: (val) => setState(() => _possuiGaragem = val)),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                      theme: theme,
                      title: "Mobiliado",
                      value: _isMobiliado,
                      onChanged: (val) => setState(() => _isMobiliado = val)),
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
