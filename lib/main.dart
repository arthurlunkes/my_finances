import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'providers/transaction_provider.dart';
import 'providers/credit_card_provider.dart';
import 'routes/app_routes.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/widgets/app_logo.dart';

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

  @override
  void initState() {
    super.initState();
    // Exibir splash por 1200ms
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CreditCardProvider()),
      ],
      child: MaterialApp.router(
        title: 'My Finances',
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
          return child!;
        },
      ),
    );
  }
}
