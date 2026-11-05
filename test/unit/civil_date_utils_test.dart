import 'package:flutter_test/flutter_test.dart';
import 'package:controle_financeiro/core/utils/civil_date_utils.dart';

void main() {
  group('CivilDateUtils', () {
    test('formatCivilDate formata YYYY-MM-DD com pad zero', () {
      expect(CivilDateUtils.formatCivilDate(2026, 4, 5), '2026-04-05');
      expect(CivilDateUtils.formatCivilDate(2026, 11, 24), '2026-11-24');
    });

    test('toBrazilianFormat converte para DD/MM/AAAA', () {
      expect(CivilDateUtils.toBrazilianFormat('2026-04-05'), '05/04/2026');
    });

    test('getDaysInMonth trata ano bissexto corretamente', () {
      expect(CivilDateUtils.getDaysInMonth(2024, 2), 29);
      expect(CivilDateUtils.getDaysInMonth(2025, 2), 28);
      expect(CivilDateUtils.getDaysInMonth(2026, 2), 28);
    });

    test('generateMonthlyDates realiza clamping em meses mais curtos', () {
      final dates = CivilDateUtils.generateMonthlyDates('2026-01-31', 3);
      expect(dates, ['2026-01-31', '2026-02-28', '2026-03-31']);
    });
  });
}

