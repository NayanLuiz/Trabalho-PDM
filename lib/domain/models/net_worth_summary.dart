class NetWorthSummary {
  final int totalInCheckingCents;
  final int totalInSavingsCents;
  final int totalInInvestmentsCents;
  final int totalCashCents;
  final int totalCreditCardDebtCents;

  const NetWorthSummary({
    this.totalInCheckingCents = 0,
    this.totalInSavingsCents = 0,
    this.totalInInvestmentsCents = 0,
    this.totalCashCents = 0,
    this.totalCreditCardDebtCents = 0,
  });

  int get totalAssetsCents =>
      totalInCheckingCents +
      totalInSavingsCents +
      totalInInvestmentsCents +
      totalCashCents;

  int get netWorthCents => totalAssetsCents - totalCreditCardDebtCents;
}

