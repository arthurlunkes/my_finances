import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/app_logo.dart';

/// Chave usada para lembrar que o usuário já viu o passo a passo inicial.
const String kOnboardingSeenKey = 'onboarding_seen';

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingScreen extends StatefulWidget {
  /// Chamado quando o usuário conclui (ou pula) o passo a passo.
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Bem-vindo ao MiResta',
      description:
          'Organize suas receitas e despesas em um só lugar e tenha o controle total do seu dinheiro, de forma simples e rápida.',
      color: AppColors.primary,
    ),
    _OnboardingPageData(
      icon: Icons.dashboard_rounded,
      title: 'Início',
      description:
          'Veja seu saldo, o total de receitas e despesas do mês e os próximos pagamentos. Toque no olho para ocultar os valores quando quiser privacidade.',
      color: AppColors.secondary,
    ),
    _OnboardingPageData(
      icon: Icons.receipt_long_rounded,
      title: 'Transações',
      description:
          'Cadastre receitas e despesas com categoria, status e parcelas. Filtre por tipo, pesquise e segure um item para editar, marcar como pago ou excluir.',
      color: AppColors.creditCard,
    ),
    _OnboardingPageData(
      icon: Icons.calendar_month_rounded,
      title: 'Calendário',
      description:
          'Acompanhe seus lançamentos por dia. Os pontos verdes e vermelhos mostram receitas e despesas, e ao tocar em uma data você vê o resumo do dia.',
      color: AppColors.savings,
    ),
    _OnboardingPageData(
      icon: Icons.add_circle_rounded,
      title: 'Tudo pronto!',
      description:
          'Use o botão "+" em qualquer tela para adicionar uma nova transação. Comece agora a cuidar das suas finanças!',
      color: AppColors.income,
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingSeenKey, true);
    widget.onDone();
  }

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(_isLastPage ? '' : 'Pular'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            _buildIndicator(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_isLastPage ? 'Começar' : 'Próximo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.icon == Icons.account_balance_wallet_rounded)
            const AppLogo(size: 96)
          else
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(page.icon, size: 64, color: page.color),
            ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
