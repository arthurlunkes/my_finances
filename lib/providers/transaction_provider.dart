import 'package:flutter/foundation.dart';
import '../data/models/transaction.dart';
import '../data/repositories/database_helper.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Filtros
  List<Transaction> get pendingTransactions =>
      _transactions.where((t) => t.isPending).toList();

  List<Transaction> get paidTransactions =>
      _transactions.where((t) => t.isPaid).toList();

  List<Transaction> get overdueTransactions =>
      _transactions.where((t) => t.isOverdue).toList();

  List<Transaction> get incomes =>
      _transactions.where((t) => t.isIncome).toList();

  List<Transaction> get expenses =>
      _transactions.where((t) => t.isExpense).toList();

  List<Transaction> get tithes =>
      _transactions.where((t) => t.isTithe).toList();

  List<Transaction> get offerings =>
      _transactions.where((t) => t.isOffering).toList();

  // Valores totais
  double get totalIncome => incomes.fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => expenses.fold(0.0, (sum, t) => sum + t.amount);

  // Totais apenas pagos (para refletir saldo real)
  double get totalIncomePaid =>
      incomes.where((t) => t.isPaid).fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpensePaid =>
      expenses.where((t) => t.isPaid).fold(0.0, (sum, t) => sum + t.amount);

  double get totalTithe => tithes.fold(0.0, (sum, t) => sum + t.amount);

  double get totalOffering => offerings.fold(0.0, (sum, t) => sum + t.amount);

  // Balance based on paid amounts (realized)
  double get balance =>
      totalIncomePaid - totalExpensePaid - totalTithe - totalOffering;

  // Próximos pagamentos (7 dias)
  List<Transaction> get upcomingPayments {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _transactions
        .where(
          (t) =>
              t.isPending && t.date.isAfter(now) && t.date.isBefore(nextWeek),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Carregar todas transações
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _db.getAllTransactions();
      _updateOverdueStatus();
    } catch (e) {
      debugPrint('Erro ao carregar transações: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar transações por período
  Future<void> loadTransactionsByDateRange(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _db.getTransactionsByDateRange(start, end);
      _updateOverdueStatus();
    } catch (e) {
      debugPrint('Erro ao carregar transações por data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar transação
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _db.insertTransaction(transaction);
      // Se for recorrente, crie a próxima ocorrência imediata
      if (transaction.isRecurrent) {
        await _createNextRecurrence(transaction);
      }
      await loadTransactions();
    } catch (e) {
      debugPrint('Erro ao adicionar transação: $e');
      rethrow;
    }
  }

  // Atualizar transação
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _db.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Erro ao atualizar transação: $e');
      rethrow;
    }
  }

  // Deletar transação
  Future<void> deleteTransaction(String id) async {
    try {
      await _db.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('Erro ao deletar transação: $e');
      rethrow;
    }
  }

  // Marcar como paga
  Future<void> markAsPaid(String id) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == id);
      final updated = transaction.copyWith(
        status: TransactionStatus.paid,
        updatedAt: DateTime.now(),
      );
      await updateTransaction(updated);
      // Se for recorrente, criar próxima ocorrência ao marcar como paga
      if (transaction.isRecurrent) {
        await _createNextRecurrence(transaction);
        await loadTransactions();
      }
    } catch (e) {
      debugPrint('Erro ao marcar como paga: $e');
      rethrow;
    }
  }

  // Cria e insere a próxima ocorrência de uma transação recorrente
  Future<void> _createNextRecurrence(Transaction transaction) async {
    try {
      // Avança um mês mantendo o mesmo dia quando possível
      DateTime nextDate;
      final year = transaction.date.month == 12
          ? transaction.date.year + 1
          : transaction.date.year;
      final month = transaction.date.month == 12
          ? 1
          : transaction.date.month + 1;
      final day = transaction.date.day;
      // Ajuste para dias que não existem no próximo mês (ex: 31)
      final lastDayOfNextMonth = DateTime(year, month + 1, 0).day;
      final safeDay = day <= lastDayOfNextMonth ? day : lastDayOfNextMonth;
      nextDate = DateTime(year, month, safeDay);

      final next = Transaction(
        id: const Uuid().v4(),
        description: transaction.description,
        amount: transaction.amount,
        date: nextDate,
        type: transaction.type,
        status: TransactionStatus.pending,
        category: transaction.category,
        isRecurrent: true,
        notes: transaction.notes,
        creditCardId: transaction.creditCardId,
        installments: transaction.installments,
        currentInstallment: transaction.installments != null
            ? (transaction.currentInstallment != null
                  ? transaction.currentInstallment! + 1
                  : 1)
            : null,
        createdAt: DateTime.now(),
      );

      await _db.insertTransaction(next);
    } catch (e) {
      debugPrint('Erro ao criar próxima recorrência: $e');
    }
  }

  // Criar transação de dízimo automaticamente (10% do salário)
  Future<void> createTitheFromIncome(Transaction income) async {
    try {
      final titheAmount = income.amount * 0.10;
      final tithe = Transaction(
        id: const Uuid().v4(),
        description: 'Dízimo - ${income.description}',
        amount: titheAmount,
        date: income.date,
        type: TransactionType.tithe,
        status: TransactionStatus.pending,
        category: 'cat_tithe',
        createdAt: DateTime.now(),
      );
      await addTransaction(tithe);
    } catch (e) {
      debugPrint('Erro ao criar dízimo: $e');
      rethrow;
    }
  }

  // Atualizar status de atrasadas
  void _updateOverdueStatus() {
    final now = DateTime.now();
    for (var transaction in _transactions) {
      if (transaction.isPending && transaction.date.isBefore(now)) {
        final updated = transaction.copyWith(
          status: TransactionStatus.overdue,
          updatedAt: DateTime.now(),
        );
        _db.updateTransaction(updated);
      }
    }
  }

  // Obter transações de um mês específico
  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactions.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();
  }

  // Obter gastos por categoria
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categoryExpenses = {};
    for (var transaction in expenses.where((t) => t.isPaid)) {
      categoryExpenses[transaction.category] =
          (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
    }
    return categoryExpenses;
  }
}
