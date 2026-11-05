import 'package:flutter_test/flutter_test.dart';
import 'package:controle_financeiro/domain/models/budget.dart';
import 'package:controle_financeiro/domain/use_cases/check_budget_limit_use_case.dart';

void main() {
  group('CheckBudgetLimitUseCase', () {
    final useCase = CheckBudgetLimitUseCase();

    test('classifica como NORMAL abaixo de 80%', () {
      final res = useCase.execute(
        categoryId: 'cat1',
        limitCents: 100000,
        spentCents: 70000,
      );

      expect(res.status, BudgetStatus.NORMAL);
      expect(res.usagePercentage, 70.0);
      expect(res.shouldTrigger80Alert, false);
      expect(res.shouldTrigger100Alert, false);
    });

    test('classifica como WARNING e aciona alerta entre 80% e 100%', () {
      final res = useCase.execute(
        categoryId: 'cat1',
        limitCents: 100000,
        spentCents: 85000,
      );

      expect(res.status, BudgetStatus.WARNING);
      expect(res.usagePercentage, 85.0);
      expect(res.shouldTrigger80Alert, true);
      expect(res.shouldTrigger100Alert, false);
    });

    test('classifica como EXCEEDED e aciona alerta acima de 100%', () {
      final res = useCase.execute(
        categoryId: 'cat1',
        limitCents: 100000,
        spentCents: 110000,
      );

      expect(res.status, BudgetStatus.EXCEEDED);
      expect(res.usagePercentage, 110.0);
      expect(res.shouldTrigger80Alert, false);
      expect(res.shouldTrigger100Alert, true);
    });
  });
}

