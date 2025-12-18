import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../providers/transaction_provider.dart';
import 'package:go_router/go_router.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactions),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Receitas'),
            Tab(text: 'Despesas'),
            Tab(text: 'Dízimos'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar transações...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.transactions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionList(provider.transactions),
                    _buildTransactionList(provider.incomes),
                    _buildTransactionList(provider.expenses),
                    _buildTransactionList([
                      ...provider.tithes,
                      ...provider.offerings,
                    ]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-transaction');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    final filteredTransactions = transactions.where((t) {
      return t.description.toLowerCase().contains(_searchQuery) ||
          t.category.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma transação encontrada',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Agrupar por mês
    final groupedByMonth = <String, List<Transaction>>{};
    for (var transaction in filteredTransactions) {
      final monthKey = DateFormatter.toMonthYear(transaction.date);
      groupedByMonth.putIfAbsent(monthKey, () => []).add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groupedByMonth.length,
      itemBuilder: (context, index) {
        final monthKey = groupedByMonth.keys.elementAt(index);
        final monthTransactions = groupedByMonth[monthKey]!;

        // Calcular total do mês
        final totalIncome = monthTransactions
            .where((t) => t.isIncome && t.isPaid)
            .fold(0.0, (sum, t) => sum + t.amount);
        final totalExpense = monthTransactions
            .where(
              (t) => (t.isExpense || t.isTithe || t.isOffering) && t.isPaid,
            )
            .fold(0.0, (sum, t) => sum + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthKey,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatWithSign(
                          totalIncome - totalExpense,
                        ),
                        style: TextStyle(
                          color: totalIncome >= totalExpense
                              ? AppColors.income
                              : AppColors.expense,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${monthTransactions.length} transações',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ...monthTransactions.map(
              (transaction) => _buildTransactionCard(transaction),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final color = _getColorByType(transaction.type);
    final isOverdue = transaction.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getIconByType(transaction.type), color: color, size: 24),
        ),
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormatter.toDayMonthYear(transaction.date),
              style: TextStyle(
                color: isOverdue ? AppColors.overdue : AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(transaction.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(transaction.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (transaction.installments != null)
              Text(
                '${transaction.currentInstallment}/${transaction.installments}x',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        onTap: () {
          context.push('/edit-transaction/${transaction.id}');
        },
        onLongPress: () {
          _showTransactionOptions(transaction);
        },
      ),
    );
  }

  void _showTransactionOptions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (transaction.isPending)
              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
                title: const Text('Marcar como Pago'),
                onTap: () {
                  context.read<TransactionProvider>().markAsPaid(
                    transaction.id,
                  );
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                context.push('/edit-transaction/${transaction.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Transação'),
        content: Text('Deseja realmente excluir "${transaction.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(
                transaction.id,
              );
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Color _getColorByType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.tithe:
        return AppColors.tithe;
      case TransactionType.offering:
        return AppColors.offering;
    }
  }

  IconData _getIconByType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.tithe:
        return Icons.church;
      case TransactionType.offering:
        return Icons.volunteer_activism;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return AppColors.pending;
      case TransactionStatus.paid:
        return AppColors.paid;
      case TransactionStatus.overdue:
        return AppColors.overdue;
      case TransactionStatus.scheduled:
        return AppColors.info;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'PENDENTE';
      case TransactionStatus.paid:
        return 'PAGO';
      case TransactionStatus.overdue:
        return 'ATRASADO';
      case TransactionStatus.scheduled:
        return 'AGENDADO';
    }
  }
}
