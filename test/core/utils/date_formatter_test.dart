import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_finances/core/utils/date_formatter.dart';

void main() {
  // DateFormat com locale pt_BR precisa dos dados de locale carregados.
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  DateTime atNoon(DateTime base, int dayOffset) =>
      DateTime(base.year, base.month, base.day + dayOffset, 12);

  group('DateFormatter.toRelative', () {
    final now = DateTime.now();

    test('hoje retorna "Hoje"', () {
      expect(DateFormatter.toRelative(atNoon(now, 0)), 'Hoje');
    });

    test('amanhã retorna "Amanhã"', () {
      expect(DateFormatter.toRelative(atNoon(now, 1)), 'Amanhã');
    });

    test('ontem retorna "Ontem"', () {
      expect(DateFormatter.toRelative(atNoon(now, -1)), 'Ontem');
    });

    test('daqui a 3 dias retorna "Em 3 dias"', () {
      expect(DateFormatter.toRelative(atNoon(now, 3)), 'Em 3 dias');
    });

    test('3 dias atrás retorna "3 dias atrás"', () {
      expect(DateFormatter.toRelative(atNoon(now, -3)), '3 dias atrás');
    });

    test('além de 7 dias volta para data completa dd/MM/yyyy', () {
      final result = DateFormatter.toRelative(atNoon(now, 30));
      expect(result, matches(r'^\d{2}/\d{2}/\d{4}$'));
    });
  });

  group('DateFormatter.toDayMonthYear', () {
    test('formata como dd/MM/yyyy', () {
      expect(DateFormatter.toDayMonthYear(DateTime(2026, 6, 25)), '25/06/2026');
    });
  });

  group('DateFormatter — verificações de data', () {
    final now = DateTime.now();

    test('isToday verdadeiro para agora, falso para ontem', () {
      expect(DateFormatter.isToday(now), isTrue);
      expect(DateFormatter.isToday(atNoon(now, -1)), isFalse);
    });

    test('isThisMonth verdadeiro para hoje', () {
      expect(DateFormatter.isThisMonth(now), isTrue);
    });

    test('isOverdue: ontem vencido, amanhã não, hoje não', () {
      expect(DateFormatter.isOverdue(atNoon(now, -1)), isTrue);
      expect(DateFormatter.isOverdue(atNoon(now, 1)), isFalse);
      expect(DateFormatter.isOverdue(atNoon(now, 0)), isFalse);
    });
  });

  group('DateFormatter — limites do mês', () {
    test('getFirstDayOfMonth retorna dia 1', () {
      expect(
        DateFormatter.getFirstDayOfMonth(DateTime(2026, 6, 25)),
        DateTime(2026, 6, 1),
      );
    });

    test('getLastDayOfMonth retorna último dia (junho = 30)', () {
      expect(
        DateFormatter.getLastDayOfMonth(DateTime(2026, 6, 15)),
        DateTime(2026, 6, 30),
      );
    });

    test('getLastDayOfMonth respeita ano bissexto (fev/2024 = 29)', () {
      expect(
        DateFormatter.getLastDayOfMonth(DateTime(2024, 2, 10)),
        DateTime(2024, 2, 29),
      );
    });
  });
}
