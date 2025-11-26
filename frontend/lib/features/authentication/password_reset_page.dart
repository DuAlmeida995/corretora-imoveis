import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// ----------------------------------------------------------------------
//                       PÁGINA DE REDEFINIÇÃO DE SENHA
// ----------------------------------------------------------------------

class PasswordResetPage extends StatefulWidget {
  final String userCpf;
  final String otpCode;

  const PasswordResetPage({
    super.key,
    required this.userCpf,
    required this.otpCode,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final AuthenticationRepository _authRepository = AuthenticationRepository();
  bool _isLoading = false;

  void _resetPassword() async {
    if (_isLoading) return;

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // --- Validações ---
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showAlert("Erro", "Por favor, preencha ambos os campos de senha.");
      return;
    }
    if (newPassword != confirmPassword) {
      _showAlert("Erro", "As senhas não coincidem. Tente novamente.");
      return;
    }
    if (newPassword.length < 6) {
      _showAlert("Erro", "A senha deve ter pelo menos 6 caracteres.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.resetPassword(
        widget.userCpf,
        widget.otpCode,
        newPassword,
      );

      if (mounted) {
        _showAlert(
          "Sucesso!",
          "Sua senha foi redefinida. Você pode fazer login.",
          onConfirm: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().contains("Exception:")
            ? e.toString().split("Exception:")[1].trim()
            : "Erro de comunicação com o servidor.";

        _showAlert("Falha no Reset", errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAlert(String title, String content, {VoidCallback? onConfirm}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: CupertinoNavigationBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.back, color: primaryColor),
        ),
        border: null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text(
                "Criar Nova Senha",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Defina sua nova senha. Ela deve ser diferente da sua senha anterior.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              _buildTextField(
                controller: _newPasswordController,
                hintText: "Nova Senha",
                icon: CupertinoIcons.lock_fill,
                theme: theme,
                fieldColor: fieldColor,
                primaryColor: primaryColor,
                obscureText: !_isNewPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(
                      () => _isNewPasswordVisible = !_isNewPasswordVisible),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _confirmPasswordController,
                hintText: "Confirme a Nova Senha",
                icon: CupertinoIcons.lock_fill,
                theme: theme,
                fieldColor: fieldColor,
                primaryColor: primaryColor,
                obscureText: !_isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() =>
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
              ),

              const Spacer(),

              // Botão Redefinir Senha
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CupertinoButton(
                  color: primaryColor,
                  onPressed: _isLoading ? null : _resetPassword,
                  borderRadius: BorderRadius.circular(14),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text(
                          "Redefinir Senha",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
