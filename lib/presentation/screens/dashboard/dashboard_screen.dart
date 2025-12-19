import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/bible_verses.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/transaction_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_cards.dart';
import 'widgets/upcoming_payments_list.dart';
import 'widgets/bible_verse_card.dart';
import '../../widgets/app_logo.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hideValues = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<TransactionProvider>();
    await provider.loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 36),
            const SizedBox(width: 10),
            Text(
              AppStrings.dashboard,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_hideValues ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _hideValues = !_hideValues;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.transactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saudação
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.toMonthYear(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Card de Saldo
                  BalanceCard(
                    balance: provider.balance,
                    income: provider.totalIncomePaid,
                    expenses: provider.totalExpensePaid,
                    hideValues: _hideValues,
                  ),
                  const SizedBox(height: 16),

                  // Cards de Resumo
                  SummaryCards(
                    totalIncome: provider.totalIncome,
                    totalExpense: provider.totalExpense,
                    totalTithe: provider.totalTithe,
                    totalOffering: provider.totalOffering,
                    hideValues: _hideValues,
                  ),
                  const SizedBox(height: 24),

                  // Versículo do Dia
                  BibleVerseCard(verse: BibleVerses.getVerseOfTheDay()),
                  const SizedBox(height: 24),

                  // Próximos Pagamentos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.upcomingPayments,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/transactions');
                        },
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  UpcomingPaymentsList(
                    transactions: provider.upcomingPayments,
                    onTap: (transaction) {
                      context.push('/edit-transaction/${transaction.id}');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia!';
    } else if (hour < 18) {
      return 'Boa tarde!';
    } else {
      return 'Boa noite!';
    }
  }
}
