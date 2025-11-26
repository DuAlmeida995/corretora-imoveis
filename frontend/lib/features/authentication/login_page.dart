import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:aura_frontend/features/authentication/forgot_password_page.dart';
import 'package:aura_frontend/features/home/home_page.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
        color: theme.brightness == Brightness.dark
            ? Colors.white12
            : Colors.grey.shade300,
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
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        if (suffixIcon != null) suffixIcon,
      ],
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de texto
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthenticationRepository _authRepository = AuthenticationRepository();
  bool _isLoading = false;

  var cpfMaskFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (_isLoading) return;

    final password = _passwordController.text;
    final rawCpf = cpfMaskFormatter.getUnmaskedText().trim();

    if (rawCpf.isEmpty || rawCpf.length != 11 || password.isEmpty) {
      _showAlert(
        title: "Dados Incompletos",
        message: "Por favor, verifique seu CPF e Senha.",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final corretor = await _authRepository.login(rawCpf, password);

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;

        if (e.toString().contains("Exception:")) {
          errorMessage = e.toString().split("Exception:")[1].trim();
        } else {
          errorMessage = "Falha de comunicação com o servidor.";
        }

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Falha no Login"),
            content: Text(errorMessage),
            actions: [
              CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAlert({required String title, required String message}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _handleMissPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, AppRoutes.signUp);
  }

  Widget _buildSignUpButton(ThemeData theme, Color primaryColor) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _navigateToSignUp,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Não tem conta? ",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            Text(
              "Cadastre-se",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
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
    final secondaryColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    Navigator.pop(context), // Volta para a OnboardingPage
                child: Icon(CupertinoIcons.back, color: primaryColor),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    Text(
                      "Aura\nImobiliária",
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Bem-vindo(a) de volta, corretor.",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: secondaryColor,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Campo de CPF
                    _buildTextField(
                      controller: _cpfController,
                      hintText: "CPF",
                      icon: CupertinoIcons.person_fill,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [cpfMaskFormatter],
                    ),
                    const SizedBox(height: 16),

                    // Campo de Senha
                    _buildTextField(
                      controller: _passwordController,
                      hintText: "Senha",
                      icon: CupertinoIcons.lock_fill,
                      obscureText: !_isPasswordVisible,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill,
                          color: secondaryColor,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botão Esqueceu a Senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _handleMissPassword,
                        child: Text(
                          "Esqueceu a senha?",
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: primaryColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Botão de Login (Principal)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CupertinoButton(
                        color: primaryColor,
                        onPressed: _isLoading ? null : _handleLogin,
                        borderRadius: BorderRadius.circular(14),
                        child: _isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white)
                            : Text(
                                "Entrar",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: backgroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botão de Cadastro (Secundário, Estilo Texto)
                    _buildSignUpButton(theme, primaryColor),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
