import 'package:flutter_test/flutter_test.dart';
import 'package:my_finances/data/models/credit_card.dart';

void main() {
  CreditCard sample() => CreditCard(
    id: 'card-1',
    name: 'Nubank',
    lastDigits: '1234',
    limit: 5000.0,
    closingDay: 10,
    dueDay: 17,
    brand: 'Mastercard',
    createdAt: DateTime(2026, 1, 1),
  );

  test('displayName mostra nome e últimos dígitos', () {
    expect(sample().displayName, 'Nubank •••• 1234');
  });

  group('Serialização JSON', () {
    test('toJson grava o limite na chave "cardLimit"', () {
      final json = sample().toJson();
      expect(json['cardLimit'], 5000.0);
      expect(json.containsKey('limit'), isFalse);
    });

    test('round-trip toJson/fromJson preserva os campos', () {
      final original = sample();
      final restored = CreditCard.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.lastDigits, original.lastDigits);
      expect(restored.limit, original.limit);
      expect(restored.closingDay, original.closingDay);
      expect(restored.dueDay, original.dueDay);
      expect(restored.brand, original.brand);
      expect(restored.isActive, original.isActive);
    });

    test('fromJson aceita a chave legada "limit"', () {
      final json = sample().toJson();
      json.remove('cardLimit');
      json['limit'] = 8000.0;

      expect(CreditCard.fromJson(json).limit, 8000.0);
    });
  });

  test('copyWith altera apenas o campo informado', () {
    final updated = sample().copyWith(limit: 10000.0);
    expect(updated.limit, 10000.0);
    expect(updated.name, 'Nubank');
  });
}
