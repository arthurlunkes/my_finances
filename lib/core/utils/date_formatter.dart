import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _dayMonth = DateFormat('dd/MM', 'pt_BR');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'pt_BR');
  static final DateFormat _monthYearShort = DateFormat('MMM/yy', 'pt_BR');
  static final DateFormat _weekday = DateFormat('EEEE', 'pt_BR');
  static final DateFormat _dayWeekday = DateFormat('dd - EEE', 'pt_BR');

  static String toDayMonthYear(DateTime date) {
    return _dayMonthYear.format(date);
  }

  static String toDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }

  static String toMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  static String toMonthYearShort(DateTime date) {
    return _monthYearShort.format(date);
  }

  static String toWeekday(DateTime date) {
    return _weekday.format(date);
  }

  static String toDayWeekday(DateTime date) {
    return _dayWeekday.format(date);
  }

  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference == -1) {
      return 'Ontem';
    } else if (difference > 1 && difference <= 7) {
      return 'Em $difference dias';
    } else if (difference < -1 && difference >= -7) {
      return '${-difference} dias atrás';
    } else {
      return toDayMonthYear(date);
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    return targetDay.isBefore(today);
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
