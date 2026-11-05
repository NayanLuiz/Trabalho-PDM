import 'package:flutter_test/flutter_test.dart';
import 'package:controle_financeiro/core/utils/money_utils.dart';

void main() {
  group('MoneyUtils', () {
    test('formatCents formata centavos inteiros para moeda brasileira BRL', () {
      expect(MoneyUtils.formatCents(100), 'R\$\xa01,00');
      expect(MoneyUtils.formatCents(125050), 'R\$\xa01.250,50');
      expect(MoneyUtils.formatCents(0), 'R\$\xa00,00');
    });

    test('parseToCents converte strings para centavos inteiros', () {
      expect(MoneyUtils.parseToCents('10,50'), 1050);
      expect(MoneyUtils.parseToCents('R\$ 1.250,50'), 125050);
      expect(MoneyUtils.parseToCents('0,00'), 0);
      expect(MoneyUtils.parseToCents(''), 0);
    });

    test('calculatePercentage calcula percentual com duas casas', () {
      expect(MoneyUtils.calculatePercentage(50, 100), 50.0);
      expect(MoneyUtils.calculatePercentage(80, 100), 80.0);
      expect(MoneyUtils.calculatePercentage(100, 80), 125.0);
    });
  });
}

