import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_finances/data/models/category.dart';

void main() {
  group('DefaultCategories', () {
    test('all = despesas + receitas (9 + 5 = 14)', () {
      expect(DefaultCategories.expenseCategories.length, 9);
      expect(DefaultCategories.incomeCategories.length, 5);
      expect(DefaultCategories.all.length, 14);
    });

    test('categorias de receita têm isIncome = true', () {
      expect(
        DefaultCategories.incomeCategories.every((c) => c.isIncome),
        isTrue,
      );
    });

    test('categorias de despesa têm isIncome = false', () {
      expect(
        DefaultCategories.expenseCategories.every((c) => !c.isIncome),
        isTrue,
      );
    });

    test('byId encontra categoria existente', () {
      expect(DefaultCategories.byId('cat_food')?.name, 'Alimentação');
      expect(DefaultCategories.byId('cat_salary')?.name, 'Salário');
    });

    test('byId retorna null para id inexistente', () {
      expect(DefaultCategories.byId('nao_existe'), isNull);
    });
  });

  group('Category.colorValue', () {
    test('converte hex de 6 dígitos para Color opaco', () {
      final cat = Category(id: 'x', name: 'X', icon: '🔧', color: 'FF6B6B');
      expect(cat.colorValue, const Color(0xFFFF6B6B));
    });
  });

  group('CategoryIcons.byId', () {
    test('retorna o ícone mapeado para a categoria', () {
      expect(CategoryIcons.byId('cat_food'), Icons.restaurant_rounded);
      expect(CategoryIcons.byId('cat_salary'), Icons.payments_rounded);
    });

    test('fallback de receita para id desconhecido', () {
      expect(
        CategoryIcons.byId('desconhecido', isIncome: true),
        Icons.attach_money_rounded,
      );
    });

    test('fallback de despesa para id desconhecido', () {
      expect(
        CategoryIcons.byId('desconhecido', isIncome: false),
        Icons.receipt_long_rounded,
      );
    });
  });

  group('Category JSON', () {
    test('round-trip toJson/fromJson preserva campos', () {
      final original = Category(
        id: 'cat_food',
        name: 'Alimentação',
        icon: '🍔',
        color: 'FFD93D',
        isDefault: true,
      );
      final restored = Category.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.color, original.color);
      expect(restored.isIncome, original.isIncome);
      expect(restored.isDefault, original.isDefault);
    });
  });
}
