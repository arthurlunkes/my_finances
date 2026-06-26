import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/models/category.dart';

class UpcomingPaymentsList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTap;

  const UpcomingPaymentsList({
    super.key,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AppColors.success.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum pagamento próximo',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _buildPaymentItem(context, transaction),
        );
      },
    );
  }

  Widget _buildPaymentItem(BuildContext context, Transaction transaction) {
    final isOverdue = DateFormatter.isOverdue(transaction.date);
    final color = isOverdue
        ? AppColors.overdue
        : _getColorByType(transaction.type);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
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
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          DateFormatter.toRelative(transaction.date),
          style: TextStyle(
            color: isOverdue ? AppColors.overdue : AppColors.textSecondary,
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
          ),
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
            if (isOverdue)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.overdue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ATRASADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => onTap(transaction),
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
}
