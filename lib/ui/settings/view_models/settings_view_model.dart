import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/local/local_auth_service.dart';
import '../../../data/services/remote/firestore_sync_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final LocalAuthService _localAuthService;
  final FirestoreSyncService _firestoreSyncService;

  ThemeMode _themeMode = ThemeMode.system;
  bool _biometricsEnabled = false;
  bool _hasPin = false;
  bool _isSyncing = false;

  SettingsViewModel({
    required LocalAuthService localAuthService,
    required FirestoreSyncService firestoreSyncService,
  })  : _localAuthService = localAuthService,
        _firestoreSyncService = firestoreSyncService;

  ThemeMode get themeMode => _themeMode;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get hasPin => _hasPin;
  bool get isSyncing => _isSyncing;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    _biometricsEnabled = await _localAuthService.isBiometricsEnabled();
    _hasPin = await _localAuthService.hasPinConfigured();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _localAuthService.setBiometricsEnabled(enabled);
    _biometricsEnabled = enabled;
    notifyListeners();
  }

  Future<void> configurePin(String pin) async {
    await _localAuthService.savePin(pin);
    _hasPin = true;
    notifyListeners();
  }

  Future<void> triggerCloudSync(String userId) async {
    _isSyncing = true;
    notifyListeners();
    try {
      await _firestoreSyncService.syncAll(userId);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

