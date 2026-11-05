/// Manipulacao de datas civis puras no formato YYYY-MM-DD.
/// Impede alteracoes indesejadas de fuso horario (timezone shifts).
class CivilDateUtils {
  /// Retorna a data civil atual do dispositivo em YYYY-MM-DD.
  static String today() {
    final now = DateTime.now();
    return formatCivilDate(now.year, now.month, now.day);
  }

  /// Formata ano, mes e dia em YYYY-MM-DD.
  static String formatCivilDate(int year, int month, int day) {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  /// Converte YYYY-MM-DD para exibicao brasileira DD/MM/AAAA.
  static String toBrazilianFormat(String civilDate) {
    final parts = civilDate.split('-');
    if (parts.length != 3) return civilDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  /// Retorna quantidade de dias de um mes/ano especifico.
  static int getDaysInMonth(int year, int month) {
    if (month == 2) {
      final bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysPerMonth[month - 1];
  }

  /// Gera datas mensais subsequentes respeitando o limite do mes (clamping).
  static List<String> generateMonthlyDates(String startDate, int occurrences) {
    final parts = startDate.split('-').map(int.tryParse).toList();
    if (parts.length != 3 || parts.any((p) => p == null)) return [startDate];

    final int startYear = parts[0]!;
    final int startMonth = parts[1]!;
    final int startDay = parts[2]!;

    final List<String> result = [startDate];
    for (int i = 1; i < occurrences; i++) {
      int targetMonth = startMonth + i;
      int targetYear = startYear;

      while (targetMonth > 12) {
        targetMonth -= 12;
        targetYear += 1;
      }

      final int maxDays = getDaysInMonth(targetYear, targetMonth);
      final int targetDay = startDay > maxDays ? maxDays : startDay;
      result.add(formatCivilDate(targetYear, targetMonth, targetDay));
    }

    return result;
  }
}

