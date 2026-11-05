import '../../core/utils/civil_date_utils.dart';

/// Caso de Uso: Gera datas para transacoes parceladas ou recorrentes mensais.
class GenerateRecurringDatesUseCase {
  List<String> execute({
    required String initialDate,
    required int totalInstallmentsOrMonths,
  }) {
    if (totalInstallmentsOrMonths <= 1) return [initialDate];
    return CivilDateUtils.generateMonthlyDates(initialDate, totalInstallmentsOrMonths);
  }
}

