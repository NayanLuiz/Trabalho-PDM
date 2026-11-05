import '../models/budget.dart';

class BudgetCheckResult {
  final String categoryId;
  final int limitCents;
  final int spentCents;
  final int remainingCents;
  final double usagePercentage;
  final BudgetStatus status;
  final bool shouldTrigger80Alert;
  final bool shouldTrigger100Alert;

  const BudgetCheckResult({
    required this.categoryId,
    required this.limitCents,
    required this.spentCents,
    required this.remainingCents,
    required this.usagePercentage,
    required this.status,
    required this.shouldTrigger80Alert,
    required this.shouldTrigger100Alert,
  });
}

/// Caso de Uso: Valida consumo de orcamento e determina disparos de alertas locais aos 80% e 100%.
class CheckBudgetLimitUseCase {
  BudgetCheckResult execute({
    required String categoryId,
    required int limitCents,
    required int spentCents,
  }) {
    final remainingCents = limitCents - spentCents;
    final double usage = limitCents > 0
        ? double.parse(((spentCents / limitCents) * 100).toStringAsFixed(2))
        : 0.0;

    BudgetStatus status;
    bool alert80 = false;
    bool alert100 = false;

    if (usage >= 100.0) {
      status = BudgetStatus.EXCEEDED;
      alert100 = true;
    } else if (usage >= 80.0) {
      status = BudgetStatus.WARNING;
      alert80 = true;
    } else {
      status = BudgetStatus.NORMAL;
    }

    return BudgetCheckResult(
      categoryId: categoryId,
      limitCents: limitCents,
      spentCents: spentCents,
      remainingCents: remainingCents,
      usagePercentage: usage,
      status: status,
      shouldTrigger80Alert: alert80,
      shouldTrigger100Alert: alert100,
    );
  }
}

