import 'dart:io';
import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:aura_frontend/data/models/corretor_model.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

import '../../data/mocks/especialidades_mock.dart';
import '../../data/mocks/bairros_atuacao_mock.dart';

// ----------------------- COMPONENTES DE INTERFACE -----------------------

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    ),
  );
}

Widget _buildProfileInfoTile({
  required ThemeData theme,
  required String title,
  required String value,
  required Color primaryColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
      ],
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
  bool enabled = true,
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
            enabled: enabled,
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

// ----------------------- PÁGINA PRINCIPAL -----------------------

class CorretorProfilePage extends StatefulWidget {
  const CorretorProfilePage({super.key});

  @override
  State<CorretorProfilePage> createState() => _CorretorProfilePageState();
}

class _CorretorProfilePageState extends State<CorretorProfilePage> {
  CorretorModel? _corretorProfile;
  bool _isLoading = true;

  final AuthenticationRepository _authRepository = AuthenticationRepository();

  late TextEditingController _prenomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _emailController;
  final List<TextEditingController> _telefoneControllers = [];

  late String _especialidadeSelecionada;
  late String _regiaoAtuacaoSelecionada;

  // Imagem
  File? _profileImage; // Arquivo local p/ upload e pré-visualização
  final ImagePicker _picker = ImagePicker();

  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future<void> _loadCorretorProfile() async {
    final profile = await _authRepository.loadProfile();

    if (mounted) {
      if (profile != null) {
        setState(() {
          _corretorProfile = profile;
          _isLoading = false;
          _initializeControllers(profile);
        });
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  void _initializeControllers(CorretorModel profile) {
    _prenomeController = TextEditingController(text: profile.prenome);
    _sobrenomeController = TextEditingController(text: profile.sobrenome);
    _emailController = TextEditingController(text: profile.email);

    final telefonesPuros =
        profile.telefone.split(',').map((t) => t.trim()).toList();
    _telefoneControllers.clear();

    if (telefonesPuros.isEmpty ||
        (telefonesPuros.length == 1 && telefonesPuros.first.isEmpty)) {
      _telefoneControllers.add(TextEditingController());
    } else {
      for (var numeroPuro in telefonesPuros) {
        final numeroFormatado = phoneMaskFormatter.maskText(numeroPuro);
        _telefoneControllers.add(TextEditingController(text: numeroFormatado));
      }
    }

    _especialidadeSelecionada = profile.especialidade;
    _regiaoAtuacaoSelecionada = profile.regiaoAtuacao;
  }

  @override
  void initState() {
    super.initState();
    _loadCorretorProfile();
  }

  @override
  void dispose() {
    _prenomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    for (final c in _telefoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTelefone() {
    if (_telefoneControllers.length < 3) {
      setState(() {
        _telefoneControllers.add(TextEditingController());
      });
    }
  }

  void _removeTelefone(int index) {
    if (_telefoneControllers.length > 1) {
      setState(() {
        _telefoneControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  void _logout() {
    _authRepository.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _saveProfileChanges() async {
    if (_isLoading) return;

    final String telefonesRaw = _telefoneControllers
        .map((c) => phoneMaskFormatter.unmaskText(c.text))
        .where((t) => t.isNotEmpty)
        .join(',');

    if (_prenomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        telefonesRaw.isEmpty) {
      _showAlert(
          "Dados Incompletos", "Prenome, Email e Telefone são obrigatórios.");
      return;
    }

    String? newImageUrl = _corretorProfile!.profileImageUrl;
    setState(() => _isLoading = true);

    try {
      // PASSO 1: UPLOAD DA IMAGEM SE UM NOVO ARQUIVO FOI SELECIONADO
      if (_profileImage != null) {
        // O uploadProfilePicture retorna a URL (String)
        newImageUrl = await _authRepository.uploadProfilePicture(
            _corretorProfile!.cpf, _profileImage!);
      }

      // PASSO 2: CONSTRÓI O MODELO DE UPDATE
      final updatedCorretor = CorretorModel(
        prenome: _prenomeController.text.trim(),
        sobrenome: _sobrenomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: telefonesRaw,
        especialidade: _especialidadeSelecionada,
        regiaoAtuacao: _regiaoAtuacaoSelecionada,

        cpf: _corretorProfile!.cpf,
        creci: _corretorProfile!.creci,
        dataNascimento: _corretorProfile!.dataNascimento,
        profileImageUrl: newImageUrl, // ⬅️ Salva a nova URL (ou a URL antiga)
      );

      // PASSO 3: CHAMA O REPOSITÓRIO PARA ATUALIZAR DADOS TEXTUAIS/BD
      await _authRepository.updateCorretorProfile(updatedCorretor);

      // SUCESSO: Atualiza o estado local (UI) e persiste
      if (mounted) {
        setState(() {
          _corretorProfile = updatedCorretor;
          _profileImage = null; // Limpa a pré-visualização local
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: CupertinoColors.activeGreen));
      }
    } catch (e) {
      // Falha: Exibe erro de API/rede
      if (mounted) {
        String errorMessage = e.toString().contains("Exception:")
            ? e.toString().split("Exception:")[1].trim()
            : "Erro de comunicação com o servidor.";

        setState(() => _isLoading = false);
        _showAlert("Erro ao Salvar", errorMessage);
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

  void _showPicker(
      List<String> items, String currentValue, Function(String) onSelected) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: items.indexOf(currentValue),
            ),
            onSelectedItemChanged: (int index) => onSelected(items[index]),
            children: List<Widget>.generate(items.length, (int index) {
              return Center(child: Text(items[index]));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required ThemeData theme,
    required String title,
    required String selectedValue,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final primaryColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final fieldColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade100;
    final accentColor = CupertinoColors.systemGrey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
              ),
            ),

            // Valor Selecionado (Destaque)
            Text(
              selectedValue,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            // Ícone de Navegação (Chevron)
            Icon(CupertinoIcons.chevron_right, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_corretorProfile == null) {
      return Center(
        child: Text("Perfil não encontrado.",
            style: TextStyle(color: primaryColor)),
      );
    }

    final CorretorModel profile = _corretorProfile!;

    final String cpfDisplay = profile.cpf;
    final String creciDisplay = profile.creci;
    final String dataNascimentoDisplay = profile.dataNascimento;
    final bool hasRemoteImage =
        profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          // HEADER
          CupertinoSliverNavigationBar(
            largeTitle: Text("Meu Perfil",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                )),
            backgroundColor: isDark ? Colors.black : Colors.white,
            border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 0.0)),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveProfileChanges,
              child: Text("Salvar",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FOTO DE PERFIL ---
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(_profileImage!,
                                      fit: BoxFit.cover)
                                  : hasRemoteImage
                                      ? Image.network(
                                          profile.profileImageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                                child:
                                                    CupertinoActivityIndicator());
                                          },
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Icon(
                                                  CupertinoIcons
                                                      .person_alt_circle_fill,
                                                  size: 100,
                                                  color: Colors.red),
                                        )
                                      : Icon(
                                          CupertinoIcons.person_alt_circle_fill,
                                          size: 100,
                                          color: Colors.grey.shade500),
                            ),
                          ),
                          // Botão Câmera/Editar
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(CupertinoIcons.camera_fill,
                                  color: isDark ? Colors.black : Colors.white,
                                  size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- INFORMAÇÕES PESSOAIS ---
                  _buildSectionHeader(theme, "Informações Pessoais"),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _prenomeController,
                      hintText: "Prenome",
                      icon: CupertinoIcons.person_crop_circle_fill,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _sobrenomeController,
                      hintText: "Sobrenome",
                      icon: CupertinoIcons.person_crop_circle,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),
                  const SizedBox(height: 12),

                  // LISTA DE TELEFONES
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._telefoneControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildTextField(
                            controller: controller,
                            hintText: "Telefone ${index + 1}",
                            icon: CupertinoIcons.phone_fill,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [phoneMaskFormatter],
                            theme: theme,
                            fieldColor: fieldColor,
                            primaryColor: primaryColor,
                            suffixIcon: _telefoneControllers.length > 1
                                ? GestureDetector(
                                    onTap: () => _removeTelefone(index),
                                    child: const Icon(
                                        CupertinoIcons.xmark_circle_fill,
                                        color: Colors.red,
                                        size: 22),
                                  )
                                : null,
                          ),
                        );
                      }),
                      // Botão adicionar telefone
                      if (_telefoneControllers.length < 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _addTelefone,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.plus_circle_fill,
                                    color: primaryColor),
                                const SizedBox(width: 6),
                                Text("Adicionar telefone",
                                    style: TextStyle(color: primaryColor)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _emailController,
                      hintText: "E-mail",
                      icon: CupertinoIcons.mail_solid,
                      keyboardType: TextInputType.emailAddress,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor),

                  const SizedBox(height: 30),

                  // --- ATUAÇÃO PROFISSIONAL (Seletores) ---
                  _buildSectionHeader(theme, "Atuação Profissional"),
                  const SizedBox(height: 16),

                  _buildSelectorTile(
                    theme: theme,
                    title: "Especialidade",
                    selectedValue: _especialidadeSelecionada,
                    icon: CupertinoIcons.tag_fill,
                    onTap: () => _showPicker(
                        especialidades,
                        _especialidadeSelecionada,
                        (newVal) =>
                            setState(() => _especialidadeSelecionada = newVal)),
                  ),
                  const SizedBox(height: 12),

                  _buildSelectorTile(
                    theme: theme,
                    title: "Região de Atuação",
                    selectedValue: _regiaoAtuacaoSelecionada,
                    icon: CupertinoIcons.location_solid,
                    onTap: () => _showPicker(
                        bairrosAtuacao,
                        _regiaoAtuacaoSelecionada,
                        (newVal) =>
                            setState(() => _regiaoAtuacaoSelecionada = newVal)),
                  ),

                  const SizedBox(height: 30),

                  // DADOS CRÍTICOS
                  _buildSectionHeader(theme, "Dados Críticos"),
                  const SizedBox(height: 16),
                  _buildProfileInfoTile(
                      theme: theme,
                      title: "CPF",
                      value: cpfDisplay,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.grey, height: 1),
                  _buildProfileInfoTile(
                      theme: theme,
                      title: "CRECI",
                      value: creciDisplay,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.grey, height: 1),
                  _buildProfileInfoTile(
                      theme: theme,
                      title: "Nascimento",
                      value: dataNascimentoDisplay,
                      primaryColor: primaryColor),
                  const Divider(color: Colors.grey, height: 1),

                  const SizedBox(height: 40),

                  // LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      color: Colors.red.shade600,
                      onPressed: _logout,
                      borderRadius: BorderRadius.circular(14),
                      child: Text("Sair da Conta",
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
