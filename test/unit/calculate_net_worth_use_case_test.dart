import 'package:flutter_test/flutter_test.dart';
import 'package:controle_financeiro/domain/models/account.dart';
import 'package:controle_financeiro/domain/models/credit_card.dart';
import 'package:controle_financeiro/domain/use_cases/calculate_net_worth_use_case.dart';

void main() {
  group('CalculateNetWorthUseCase', () {
    test('calcula patrimonio liquido somando ativos e subtraindo faturas de cartao', () {
      final useCase = CalculateNetWorthUseCase();

      final accounts = [
        const Account(
          id: '1',
          userId: 'u1',
          name: 'Nubank CC',
          type: AccountType.CHECKING,
          balanceCents: 200000, // R$ 2.000,00
          color: '#000',
          createdAt: '',
          updatedAt: '',
        ),
        const Account(
          id: '2',
          userId: 'u1',
          name: 'XP Investimentos',
          type: AccountType.INVESTMENT,
          balanceCents: 1000000, // R$ 10.000,00
          color: '#000',
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final cards = [
        const CreditCard(
          id: 'c1',
          userId: 'u1',
          name: 'Inter Black',
          limitCents: 500000,
          closingDay: 20,
          dueDay: 28,
          color: '#000',
          currentInvoiceCents: 150000, // R$ 1.500,00
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final summary = useCase.execute(accounts: accounts, creditCards: cards);

      expect(summary.totalInCheckingCents, 200000);
      expect(summary.totalInInvestmentsCents, 1000000);
      expect(summary.totalCreditCardDebtCents, 150000);
      expect(summary.totalAssetsCents, 1200000); // 12.000,00
      expect(summary.netWorthCents, 1050000); // 10.500,00
    });
  });
}

