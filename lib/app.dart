import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'ui/accounts_cards/view_models/accounts_view_model.dart';
import 'ui/auth/view_models/auth_view_model.dart';
import 'ui/auth/views/login_view.dart';
import 'ui/auth/views/pin_lock_view.dart';
import 'ui/budgets/view_models/budgets_view_model.dart';
import 'ui/dashboard/view_models/dashboard_view_model.dart';
import 'ui/goals/view_models/goals_view_model.dart';
import 'ui/home/home_nav_scaffold.dart';
import 'ui/settings/view_models/settings_view_model.dart';
import 'ui/transactions/view_models/transactions_view_model.dart';

class ControleFinanceiroApp extends StatelessWidget {
  const ControleFinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return MaterialApp(
      title: 'Gestão Financeira & Metas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsVm.themeMode,
      home: _resolveInitialScreen(authVm),
    );
  }

  Widget _resolveInitialScreen(AuthViewModel authVm) {
    if (!authVm.isAuthenticated) {
      return const LoginView();
    }
    if (authVm.isLocked) {
      return const PinLockView();
    }
    return const HomeNavScaffold();
  }
}

