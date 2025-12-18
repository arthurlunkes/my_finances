import 'package:flutter/foundation.dart';
import '../data/models/credit_card.dart';
import '../data/models/transaction.dart';
import '../data/repositories/database_helper.dart';

class CreditCardProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<CreditCard> _cards = [];
  bool _isLoading = false;

  List<CreditCard> get cards => _cards;
  bool get isLoading => _isLoading;

  List<CreditCard> get activeCards => _cards.where((c) => c.isActive).toList();

  // Carregar todos os cartões
  Future<void> loadCreditCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _db.getAllCreditCards();
    } catch (e) {
      debugPrint('Erro ao carregar cartões: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar cartão
  Future<void> addCreditCard(CreditCard card) async {
    try {
      await _db.insertCreditCard(card);
      await loadCreditCards();
    } catch (e) {
      debugPrint('Erro ao adicionar cartão: $e');
      rethrow;
    }
  }

  // Atualizar cartão
  Future<void> updateCreditCard(CreditCard card) async {
    try {
      await _db.updateCreditCard(card);
      await loadCreditCards();
    } catch (e) {
      debugPrint('Erro ao atualizar cartão: $e');
      rethrow;
    }
  }

  // Deletar cartão
  Future<void> deleteCreditCard(String id) async {
    try {
      await _db.deleteCreditCard(id);
      await loadCreditCards();
    } catch (e) {
      debugPrint('Erro ao deletar cartão: $e');
      rethrow;
    }
  }

  // Obter cartão por ID
  CreditCard? getCardById(String id) {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calcular limite disponível (requer transações)
  double getAvailableLimit(String cardId, List<Transaction> transactions) {
    final card = getCardById(cardId);
    if (card == null) return 0.0;

    final cardTransactions = transactions
        .where((t) => t.creditCardId == cardId && t.isPending)
        .toList();

    final usedAmount = cardTransactions.fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );

    return card.limit - usedAmount;
  }

  // Calcular valor da fatura atual
  double getCurrentInvoiceAmount(
    String cardId,
    List<Transaction> transactions,
  ) {
    final card = getCardById(cardId);
    if (card == null) return 0.0;

    final closingDate = card.getCurrentInvoiceClosingDate();

    // Transações entre último fechamento e próximo fechamento
    final invoiceTransactions = transactions.where((t) {
      return t.creditCardId == cardId &&
          t.date.isBefore(closingDate) &&
          t.date.isAfter(closingDate.subtract(const Duration(days: 30)));
    }).toList();

    return invoiceTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  // Calcular uso do cartão em %
  double getCardUsagePercentage(String cardId, List<Transaction> transactions) {
    final card = getCardById(cardId);
    if (card == null) return 0.0;

    final availableLimit = getAvailableLimit(cardId, transactions);
    final usedAmount = card.limit - availableLimit;

    return (usedAmount / card.limit) * 100;
  }
}
