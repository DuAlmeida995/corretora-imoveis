import 'package:aura_frontend/data/models/imovel_model.dart';
import 'package:aura_frontend/features/authentication/forgot_password_page.dart';
import 'package:aura_frontend/features/authentication/onboarding_page.dart';
import 'package:aura_frontend/features/authentication/otp_verification_page.dart';
import 'package:aura_frontend/features/authentication/password_reset_page.dart';
import 'package:aura_frontend/features/authentication/privacy_policy.dart';
import 'package:aura_frontend/features/authentication/signup_page.dart';
import 'package:aura_frontend/features/client_registration/client_registration_page.dart';
import 'package:aura_frontend/features/home/home_page.dart';
import 'package:aura_frontend/features/home/imovel_detail_page.dart';
import 'package:aura_frontend/features/home/imovel_filter_page.dart';
import 'package:aura_frontend/features/imovel_registration/imovel_registration_page.dart';
import 'package:aura_frontend/features/pagamentos/pagamentos_cadastro_page.dart';
import 'package:aura_frontend/features/profile/corretor_profile_page.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_frontend/features/authentication/login_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    await windowManager.ensureInitialized();

    final display = await screenRetriever.getPrimaryDisplay();
    final screenSize = display.size;

    final width = screenSize.width * 0.25;
    final height = screenSize.height * 0.8;

    const title = 'Aura Corretora Imobiliária';

    final windowOptions = WindowOptions(
      size: Size(width, height),
      center: true,
      backgroundColor: Colors.transparent,
      title: title,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setSize(Size(width, height));
      await windowManager.center();
      await windowManager.setResizable(true);
      await windowManager.setIcon('assets/icones/icone3.png');
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Corretora Imobiliária',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt', 'BR'), // Suporte ao Português do Brasil
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
          surface: Colors.white,
          onSurface: Colors.black87,
          background: Colors.white,
          onBackground: Colors.black87,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoutes.onboarding,
      routes: {
        // Rotas sem argumentos
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.signUp: (context) => const SignUpPage(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.privacyPolicy: (context) => const PrivacyPolicyPage(),
        AppRoutes.onboarding: (context) => const OnboardingPage(),
        AppRoutes.propertyRegistration: (context) =>
            const PropertyRegistrationPage(),
        AppRoutes.perfilCorretor: (context) => const CorretorProfilePage(),
        AppRoutes.pagamentosCadastro: (context) =>
            const PagamentoRegistrationPage(),
        AppRoutes.perfilCadastroCliente: (context) =>
            const ClientRegistrationPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.propertyDetails:
            final imovelArgument = settings.arguments as ImovelModel;
            return CupertinoPageRoute(
              builder: (context) => PropertyPage(imovel: imovelArgument),
            );

          case AppRoutes.otpVerification:
            final cpfIdentifier = settings.arguments as String;
            return CupertinoPageRoute(
              builder: (context) => OtpVerificationPage(cpf: cpfIdentifier),
            );

          case AppRoutes.filters:
            return CupertinoPageRoute(
              builder: (context) => const FilterImovelPage(),
              fullscreenDialog: true,
              settings: settings,
            );

          case AppRoutes.resetPassword:
            final args = settings.arguments as Map<String, String>;

            return CupertinoPageRoute(
              builder: (context) => PasswordResetPage(
                userCpf: args['cpf']!,
                otpCode: args['otpCode']!,
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
