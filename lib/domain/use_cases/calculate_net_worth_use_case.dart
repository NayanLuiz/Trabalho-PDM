import '../models/account.dart';
import '../models/credit_card.dart';
import '../models/net_worth_summary.dart';

/// Caso de Uso: Calculo de Evolucao Patrimonial e Composicao de Ativos vs Passivos.
class CalculateNetWorthUseCase {
  NetWorthSummary execute({
    required List<Account> accounts,
    required List<CreditCard> creditCards,
  }) {
    int checking = 0;
    int savings = 0;
    int investments = 0;
    int cash = 0;

    for (final acc in accounts) {
      if (acc.isArchived) continue;
      switch (acc.type) {
        case AccountType.CHECKING:
          checking += acc.balanceCents;
          break;
        case AccountType.SAVINGS:
          savings += acc.balanceCents;
          break;
        case AccountType.INVESTMENT:
          investments += acc.balanceCents;
          break;
        case AccountType.CASH:
          cash += acc.balanceCents;
          break;
      }
    }

    int creditCardDebt = 0;
    for (final card in creditCards) {
      creditCardDebt += card.currentInvoiceCents;
    }

    return NetWorthSummary(
      totalInCheckingCents: checking,
      totalInSavingsCents: savings,
      totalInInvestmentsCents: investments,
      totalCashCents: cash,
      totalCreditCardDebtCents: creditCardDebt,
    );
  }
}

