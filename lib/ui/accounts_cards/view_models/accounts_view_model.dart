import 'package:flutter/foundation.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/credit_card.dart';

class AccountsViewModel extends ChangeNotifier {
  final AccountRepository _accountRepo;

  List<Account> _accounts = [];
  List<CreditCard> _creditCards = [];
  bool _isLoading = false;

  AccountsViewModel(this._accountRepo);

  List<Account> get accounts => _accounts;
  List<CreditCard> get creditCards => _creditCards;
  bool get isLoading => _isLoading;

  Future<void> loadData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _accountRepo.getAccounts(userId),
        _accountRepo.getCreditCards(userId),
      ]);
      _accounts = results[0] as List<Account>;
      _creditCards = results[1] as List<CreditCard>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(Account account) async {
    await _accountRepo.saveAccount(account);
    await loadData(account.userId);
  }

  Future<void> addCreditCard(CreditCard card) async {
    await _accountRepo.saveCreditCard(card);
    await loadData(card.userId);
  }
}

