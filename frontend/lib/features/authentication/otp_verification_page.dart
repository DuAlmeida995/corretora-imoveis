import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:aura_frontend/features/authentication/password_reset_page.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationPage extends StatefulWidget {
  final String cpf;

  const OtpVerificationPage({super.key, required this.cpf});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final int _otpLength = 6;
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;

  String _enteredOtp = '';

  final AuthenticationRepository _authRepository = AuthenticationRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    for (int i = 0; i < _otpLength; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1) {
          if (i < _otpLength - 1) {
            _focusNodes[i + 1].requestFocus();
          } else {
            _focusNodes[i].unfocus();
          }
        }
        _updateOtp();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateOtp() {
    _enteredOtp = _otpControllers.map((c) => c.text).join();
    setState(() {});
  }

  void _verifyOtp() async {
    if (_enteredOtp.length != _otpLength || _isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _authRepository.verifyOtp(widget.cpf, _enteredOtp);

      if (mounted) {
        final arguments = {
          'cpf': widget.cpf,
          'otpCode': _enteredOtp,
        };

        Navigator.pushNamed(
          context,
          AppRoutes.resetPassword,
          arguments: arguments,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().contains("Exception:")
            ? e.toString().split("Exception:")[1].trim()
            : "Erro de comunicação. O código pode ter expirado.";

        _showAlert("Falha na Verificação", errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final accentColor = CupertinoColors.systemGrey;

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
                "Confirme o Código",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Digite o código de 6 dígitos enviado para o seu e-mail.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return _buildOtpField(theme, index);
                }),
              ),
              const SizedBox(height: 30),
              Center(
                child: CupertinoButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Novo código enviado! (Mock)')),
                    );
                  },
                  child: Text("Reenviar código",
                      style: TextStyle(color: primaryColor)),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CupertinoButton(
                  color: primaryColor,
                  onPressed: (_enteredOtp.length == _otpLength && !_isLoading)
                      ? _verifyOtp
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : Text(
                          "Verificar",
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

  // Widget para cada campo de dígito OTP
  Widget _buildOtpField(ThemeData theme, int index) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _focusNodes[index].hasFocus ? primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: CupertinoTextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: theme.textTheme.headlineSmall
              ?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
          cursorColor: primaryColor,
          decoration: const BoxDecoration(border: null),
          padding: EdgeInsets.zero,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            _updateOtp();
          },
        ),
      ),
    );
  }
}
