import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'providers/transaction_provider.dart';
import 'providers/credit_card_provider.dart';
import 'routes/app_routes.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientação para portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar formatação de data em português
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyFinancesApp());
}

class MyFinancesApp extends StatefulWidget {
  const MyFinancesApp({super.key});

  @override
  State<MyFinancesApp> createState() => _MyFinancesAppState();
}

class _MyFinancesAppState extends State<MyFinancesApp> {
  bool _showSplash = true;
  bool _onboardingSeen = true;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
    // Exibir splash por 1200ms
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(kOnboardingSeenKey) ?? false;
    if (mounted) setState(() => _onboardingSeen = seen);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CreditCardProvider()),
      ],
      child: MaterialApp.router(
        title: 'MiResta',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router,
        builder: (context, child) {
          // Enquanto estiver mostrando a splash, exibimos o widget de splash
          if (_showSplash) {
            return const SplashScreen();
          }
          // Passo a passo inicial na primeira vez que o app é aberto
          if (!_onboardingSeen) {
            return OnboardingScreen(
              onDone: () => setState(() => _onboardingSeen = true),
            );
          }
          return child!;
        },
      ),
    );
  }
}
