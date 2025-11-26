import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:aura_frontend/features/authentication/otp_verification_page.dart';
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
  List<TextInputFormatter>? inputFormatters,
  TextInputType keyboardType = TextInputType.text,
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
      ],
    ),
  );
}

// ----------------------------------------------------------------------
//                       PÁGINA PRINCIPAL
// ----------------------------------------------------------------------

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _cpfController = TextEditingController();

  final cpfMaskFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  bool _isLoading = false;
  final AuthenticationRepository _authRepository = AuthenticationRepository();

  void _requestOtp() async {
    if (_isLoading) return;

    final rawCpf = cpfMaskFormatter.getUnmaskedText();

    if (rawCpf.length == 11) {
      setState(() => _isLoading = true);

      try {
        await _authRepository.requestOtp(rawCpf);

        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.otpVerification,
            arguments: rawCpf,
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = e.toString().contains("Exception:")
              ? e.toString().split("Exception:")[1].trim()
              : "Não foi possível solicitar o código. Verifique sua conexão.";

          _showAlert("Falha na Solicitação", errorMessage);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      _showAlert(
          "CPF Inválido", "Por favor, insira um CPF completo para continuar.");
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
                "Recuperar Senha",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Insira seu CPF. Enviaremos um código de 6 dígitos para o e-mail cadastrado.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Campo de CPF
              _buildTextField(
                controller: _cpfController,
                hintText: "CPF (XXX.XXX.XXX-XX)",
                icon: CupertinoIcons.number_circle_fill,
                theme: theme,
                fieldColor: fieldColor,
                primaryColor: primaryColor,
                keyboardType: TextInputType.number,
                inputFormatters: [cpfMaskFormatter],
              ),

              const Spacer(),

              // Botão para Solicitar Código
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CupertinoButton(
                  color: primaryColor,
                  onPressed: _isLoading ? null : _requestOtp,
                  borderRadius: BorderRadius.circular(14),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text(
                          "Solicitar Código",
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
