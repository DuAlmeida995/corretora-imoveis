import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  final String _policyMarkdown = """
**Data de Vigência:** 9 de Novembro de 2025

A Aura Corretora Imobiliária ("Aura") valoriza a privacidade e a proteção dos dados pessoais de seus Usuários (Corretores, Proprietários e Adquirentes), em conformidade com a Lei nº 13.709/2018 (Lei Geral de Proteção de Dados - LGPD).

## 1. Dados Coletados e Finalidade (Base Legal: Execução Contratual e Legítimo Interesse)

Coletamos os dados estritamente necessários para a gestão de imóveis, contratos e análise de risco:

* **Identificação Pessoal:** Nome, CPF, Data de Nascimento, Telefone, Email. *Finalidade:* Cadastro e contato essencial.
* **Financeiros/Risco:** Pontuação de Crédito (Adquirente), Histórico de Pagamentos. *Finalidade:* Análise de viabilidade contratual e gestão de riscos.
* **Contratuais/Ativos:** Nº CRECI (Corretor), Matrícula do Imóvel, Valores Venais, Histórico de Contratos. *Finalidade:* Execução de contratos e conformidade regulatória.

## 2. Tratamento e Compartilhamento

A Aura tratará seus dados para as seguintes finalidades:
* Execução e Gestão de Contratos.
* Segurança e Conformidade (Ex: CRECI, Receita Federal).
* Melhoria do Serviço (Legítimo Interesse): Análise de performance de imóveis e perfis.

Seus dados **não serão vendidos**. Eles poderão ser compartilhados, quando estritamente necessário, com: *Cartórios de Registro de Imóveis*, *Instituições Financeiras* e *outras partes envolvidas diretamente no contrato*.

## 3. Direitos do Titular (LGPD)

Você, como titular dos dados, possui os seguintes direitos:
* Acessar e confirmar a existência do tratamento.
* Corrigir dados incompletos ou desatualizados.
* Solicitar a anonimização, bloqueio ou eliminação de dados desnecessários.

O canal para exercer seus direitos é através do e-mail **[seu-contato-DPO]@aura.com**.

## 4. Aceite

Ao clicar em "Aceitar", você declara ter lido, compreendido e concordado com o tratamento de seus dados pessoais para as finalidades descritas nesta política, sob as bases legais de Execução Contratual e Legítimo Interesse.
""";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScroll() {
    if (_scrollController.position.extentAfter == 0 && !_hasScrolledToBottom) {
      setState(() {
        _hasScrolledToBottom = true;
      });
    }
  }

  void _onAccept() {
    if (!_hasScrolledToBottom) {
      _showAlert("Leia a Política",
          "Você deve rolar até o final da política para aceitar.");
      return;
    }
    Navigator.pop(context, true);
  }

  void _onDecline() {
    _showAlert("Recusa",
        "Para usar o sistema, você precisa aceitar a Política de Privacidade.",
        onConfirm: () {
      // Esta ação só será executada após o usuário clicar em 'OK' no alerta.
      Navigator.pop(context, false);
    });
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

  MarkdownStyleSheet _buildMarkdownStyle(ThemeData theme, Color primaryColor) {
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(
        color: primaryColor.withOpacity(0.85),
        height: 1.6,
        fontSize: 16,
      ),
      h1: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: primaryColor,
        fontSize: 24,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: primaryColor,
        fontSize: 18,
      ),
      // Estilo para listas (bullet points)
      listBullet: theme.textTheme.bodyLarge?.copyWith(
        color: primaryColor.withOpacity(0.9),
        height: 1.6,
      ),
      strong: theme.textTheme.bodyLarge?.copyWith(
        // Estilo para **negrito**
        fontWeight: FontWeight.w800,
        color: primaryColor.withOpacity(0.95),
        fontSize: 16,
      ),
      listIndent: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final accentColor = CupertinoColors.systemBlue;
    final declineColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  "Política de Privacidade",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                backgroundColor: isDark ? Colors.black : Colors.white,
                border: null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: _policyMarkdown,
                        selectable: false,
                        styleSheet: _buildMarkdownStyle(theme, primaryColor),
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                  top: 12, bottom: 24, left: 16, right: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Botão de Negar
                  Expanded(
                    child: CupertinoButton(
                      color: declineColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: _onDecline,
                      borderRadius: BorderRadius.circular(12),
                      child: Text(
                        "Negar",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botão de Aceitar
                  Expanded(
                    child: CupertinoButton(
                      color: _hasScrolledToBottom ? accentColor : declineColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: _hasScrolledToBottom ? _onAccept : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Text(
                        "Aceitar",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
