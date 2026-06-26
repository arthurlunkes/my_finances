import 'package:flutter_test/flutter_test.dart';
import 'package:my_finances/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test(
      'formata valor no padrão brasileiro (vírgula decimal, ponto milhar)',
      () {
        final result = CurrencyFormatter.format(1234.56);
        expect(result, contains('1.234,56'));
        expect(result, contains(r'R$'));
      },
    );

    test('formata zero com duas casas decimais', () {
      expect(CurrencyFormatter.format(0), contains('0,00'));
    });
  });

  group('CurrencyFormatter.formatWithSign', () {
    test('prefixa "+ " para valores positivos', () {
      final result = CurrencyFormatter.formatWithSign(100);
      expect(result, startsWith('+ '));
      expect(result, contains('100,00'));
    });

    test('prefixa "- " para valores negativos (usando valor absoluto)', () {
      final result = CurrencyFormatter.formatWithSign(-100);
      expect(result, startsWith('- '));
      expect(result, contains('100,00'));
    });

    test('zero é tratado como positivo', () {
      expect(CurrencyFormatter.formatWithSign(0), startsWith('+ '));
    });
  });

  group('CurrencyFormatter.parse', () {
    test('faz parse de valor formatado com R\$ e separadores', () {
      expect(CurrencyFormatter.parse('R\$ 1.234,56'), 1234.56);
    });

    test('faz parse de valor simples com vírgula decimal', () {
      expect(CurrencyFormatter.parse('100,50'), 100.50);
    });

    test('faz parse de milhões', () {
      expect(CurrencyFormatter.parse('1.000.000,00'), 1000000.0);
    });

    test('retorna 0.0 para texto inválido', () {
      expect(CurrencyFormatter.parse('abc'), 0.0);
    });

    test('retorna 0.0 para string vazia', () {
      expect(CurrencyFormatter.parse(''), 0.0);
    });
  });

  group('CurrencyFormatter.formatCompact', () {
    test('abrevia milhares com K', () {
      expect(CurrencyFormatter.formatCompact(1500), 'R\$ 1.5K');
    });

    test('abrevia milhões com M', () {
      expect(CurrencyFormatter.formatCompact(2500000), 'R\$ 2.5M');
    });

    test('usa formato completo abaixo de mil', () {
      expect(CurrencyFormatter.formatCompact(999), contains('999,00'));
    });

    test('1000 é o limite para abreviação em K', () {
      expect(CurrencyFormatter.formatCompact(1000), 'R\$ 1.0K');
    });
  });
}
