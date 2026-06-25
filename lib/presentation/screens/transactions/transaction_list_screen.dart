import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../providers/transaction_provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_logo.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 32),
            SizedBox(width: 10),
            Text(AppStrings.transactions),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Receitas'),
            Tab(text: 'Despesas'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar transações...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 56,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma transação por aqui',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Toque em "Nova Transação" para começar',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
            .where((t) => t.isExpense && t.isPaid)
            .fold(0.0, (sum, t) => sum + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        monthKey,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ${monthTransactions.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (totalIncome >= totalExpense
                              ? AppColors.income
                              : AppColors.expense)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CurrencyFormatter.formatWithSign(
                        totalIncome - totalExpense,
                      ),
                      style: TextStyle(
                        color: totalIncome >= totalExpense
                            ? AppColors.income
                            : AppColors.expense,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...monthTransactions.map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                  builder: (context, v, child) {
                    return Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, (1 - v) * 6),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTransactionCard(transaction),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final color = _getColorByType(transaction.type);
    final statusColor = _getStatusColor(transaction.status);
    final isOverdue = transaction.isOverdue;
    final sign = transaction.isIncome ? '+ ' : '- ';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/edit-transaction/${transaction.id}'),
        onLongPress: () => _showTransactionOptions(transaction),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  CategoryIcons.byId(
                    transaction.category,
                    isIncome: transaction.isIncome,
                  ),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusText(transaction.status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            DateFormatter.toDayMonthYear(transaction.date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue
                                  ? AppColors.overdue
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${CurrencyFormatter.format(transaction.amount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (transaction.installments != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.currentInstallment}/${transaction.installments}x',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionOptions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          if (transaction.isPending)
            ListTile(
              leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
              title: const Text('Marcar como Pago'),
              onTap: () {
                context.read<TransactionProvider>().markAsPaid(transaction.id);
                Navigator.pop(context);
              },
            ),
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              context.push('/edit-transaction/${transaction.id}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: AppColors.error),
            title: const Text('Excluir'),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(transaction);
            },
          ),
          const SizedBox(height: 8),
        ],
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
