import 'package:flutter/foundation.dart';
import '../../../data/repositories/goal_repository.dart';
import '../../../domain/models/goal.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalRepository _goalRepo;

  List<Goal> _goals = [];
  bool _isLoading = false;

  GoalsViewModel(this._goalRepo);

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  int get totalSavedCents => _goals.fold(0, (sum, g) => sum + g.currentCents);
  int get totalTargetCents => _goals.fold(0, (sum, g) => sum + g.targetCents);

  Future<void> loadGoals(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _goalRepo.getGoals(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGoal(Goal goal) async {
    await _goalRepo.saveGoal(goal);
    await loadGoals(goal.userId);
  }

  Future<void> deposit(String goalId, int amountCents, String userId) async {
    await _goalRepo.depositToGoal(goalId, amountCents);
    await loadGoals(userId);
  }
}

