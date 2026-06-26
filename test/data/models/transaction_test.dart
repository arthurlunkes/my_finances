import 'package:flutter_test/flutter_test.dart';
import 'package:my_finances/data/models/transaction.dart';

void main() {
  Transaction sample({
    TransactionType type = TransactionType.income,
    TransactionStatus status = TransactionStatus.paid,
    bool isRecurrent = false,
  }) {
    return Transaction(
      id: 'tx-1',
      description: 'Salário',
      amount: 3500.0,
      date: DateTime(2026, 6, 5),
      type: type,
      status: status,
      category: 'cat_salary',
      isRecurrent: isRecurrent,
      createdAt: DateTime(2026, 6, 1, 8, 30),
    );
  }

  group('Getters de tipo e status', () {
    test('receita: isIncome true, isExpense false', () {
      final t = sample(type: TransactionType.income);
      expect(t.isIncome, isTrue);
      expect(t.isExpense, isFalse);
    });

    test('despesa: isExpense true, isIncome false', () {
      final t = sample(type: TransactionType.expense);
      expect(t.isExpense, isTrue);
      expect(t.isIncome, isFalse);
    });

    test('status reflete nos getters', () {
      expect(sample(status: TransactionStatus.paid).isPaid, isTrue);
      expect(sample(status: TransactionStatus.pending).isPending, isTrue);
      expect(sample(status: TransactionStatus.overdue).isOverdue, isTrue);
    });
  });

  group('copyWith', () {
    test('altera apenas os campos informados', () {
      final original = sample();
      final updated = original.copyWith(
        amount: 4000.0,
        status: TransactionStatus.pending,
      );

      expect(updated.amount, 4000.0);
      expect(updated.status, TransactionStatus.pending);
      // Inalterados
      expect(updated.id, original.id);
      expect(updated.description, original.description);
      expect(updated.type, original.type);
    });
  });

  group('Serialização JSON', () {
    test('round-trip toJson/fromJson preserva os campos', () {
      final original = sample(
        type: TransactionType.expense,
        status: TransactionStatus.overdue,
        isRecurrent: true,
      );

      final restored = Transaction.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.description, original.description);
      expect(restored.amount, original.amount);
      expect(restored.date, original.date);
      expect(restored.type, original.type);
      expect(restored.status, original.status);
      expect(restored.category, original.category);
      expect(restored.isRecurrent, isTrue);
      expect(restored.createdAt, original.createdAt);
    });

    test('toJson grava booleano isRecurrent como 1/0', () {
      expect(sample(isRecurrent: true).toJson()['isRecurrent'], 1);
      expect(sample(isRecurrent: false).toJson()['isRecurrent'], 0);
    });

    test('fromJson aceita isRecurrent em formatos variados (1, true, "1")', () {
      Map<String, dynamic> base() => sample().toJson();

      expect(
        Transaction.fromJson({...base(), 'isRecurrent': 1}).isRecurrent,
        isTrue,
      );
      expect(
        Transaction.fromJson({...base(), 'isRecurrent': true}).isRecurrent,
        isTrue,
      );
      expect(
        Transaction.fromJson({...base(), 'isRecurrent': '1'}).isRecurrent,
        isTrue,
      );
      expect(
        Transaction.fromJson({...base(), 'isRecurrent': 0}).isRecurrent,
        isFalse,
      );
    });

    test('fromJson converte amount enviado como string', () {
      final json = {...sample().toJson(), 'amount': '1234.50'};
      expect(Transaction.fromJson(json).amount, 1234.50);
    });
  });
}
