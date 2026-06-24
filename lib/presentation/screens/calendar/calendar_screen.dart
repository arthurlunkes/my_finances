import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../providers/transaction_provider.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.calendar)),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildCalendarCard(provider),
              const SizedBox(height: 4),
              Expanded(child: _buildTransactionsList(provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarCard(TransactionProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'pt_BR',
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: _focusedDay,
        availableGestures: AvailableGestures.horizontalSwipe,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) {
          return provider.transactions
              .where((t) => isSameDay(t.date, day))
              .toList();
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        rowHeight: 46,
        daysOfWeekHeight: 28,
        calendarStyle: CalendarStyle(
          isTodayHighlighted: true,
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(5),
          defaultTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: const TextStyle(
            color: AppColors.expense,
            fontWeight: FontWeight.w500,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          markersMaxCount: 0, // usamos marcadores customizados
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.expense,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: const EdgeInsets.symmetric(vertical: 12),
          titleTextStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          titleTextFormatter: (date, locale) {
            final text = DateFormatter.toMonthYear(date);
            return text[0].toUpperCase() + text.substring(1);
          },
          leftChevronIcon: _chevron(Icons.chevron_left_rounded),
          rightChevronIcon: _chevron(Icons.chevron_right_rounded),
          leftChevronMargin: const EdgeInsets.only(left: 8),
          rightChevronMargin: const EdgeInsets.only(right: 8),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final txs = events.cast<Transaction>();
            final hasIncome = txs.any((t) => t.isIncome);
            final hasExpense = txs.any((t) => t.isExpense);
            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasIncome) _dot(AppColors.income),
                  if (hasIncome && hasExpense) const SizedBox(width: 3),
                  if (hasExpense) _dot(AppColors.expense),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _chevron(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTransactionsList(TransactionProvider provider) {
    if (_selectedDay == null) {
      return const Center(child: Text('Selecione uma data'));
    }

    final dayTransactions = provider.transactions
        .where((t) => isSameDay(t.date, _selectedDay))
        .toList();

    final totalIncome = dayTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = dayTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayHeader(dayTransactions.length, totalIncome, totalExpense),
        Expanded(
          child: dayTransactions.isEmpty
              ? _buildEmptyDay()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: dayTransactions.length,
                  itemBuilder: (context, index) =>
                      _buildTransactionCard(dayTransactions[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(int count, double income, double expense) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.toDayMonthYear(_selectedDay!),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  count == 1 ? '1 transação' : '$count transações',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (income > 0)
                _miniAmount(
                  Icons.arrow_downward_rounded,
                  income,
                  AppColors.income,
                ),
              if (expense > 0)
                _miniAmount(
                  Icons.arrow_upward_rounded,
                  expense,
                  AppColors.expense,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniAmount(IconData icon, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            CurrencyFormatter.format(value),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 56,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma transação neste dia',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final color = transaction.isIncome ? AppColors.income : AppColors.expense;
    final categoryName =
        DefaultCategories.byId(transaction.category)?.name ?? 'Outros';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
        title: Text(transaction.description),
        subtitle: Text('$categoryName • ${_getStatusText(transaction.status)}'),
        trailing: Text(
          CurrencyFormatter.formatWithSign(
            transaction.isIncome ? transaction.amount : -transaction.amount,
          ),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        onTap: () => context.push('/edit-transaction/${transaction.id}'),
      ),
    );
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pendente';
      case TransactionStatus.paid:
        return 'Pago';
      case TransactionStatus.overdue:
        return 'Atrasado';
      case TransactionStatus.scheduled:
        return 'Agendado';
    }
  }
}
