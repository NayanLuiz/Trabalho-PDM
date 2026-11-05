import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/services/local/local_auth_service.dart';
import '../../../data/services/remote/firebase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuthService _firebaseAuthService;
  final LocalAuthService _localAuthService;

  User? _currentUser;
  bool _isLocalAdmin = false;
  bool _isLoading = false;
  bool _isLocked = true;
  String? _errorMessage;

  AuthViewModel({
    required FirebaseAuthService firebaseAuthService,
    required LocalAuthService localAuthService,
  })  : _firebaseAuthService = firebaseAuthService,
        _localAuthService = localAuthService {
    _currentUser = _firebaseAuthService.currentUser;
    _firebaseAuthService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isLocalAdmin || _currentUser != null;
  String get activeUserId => _isLocalAdmin ? 'admin_local' : (_currentUser?.uid ?? 'local_user');
  bool get isLoading => _isLoading;
  bool get isLocked => _isLocked;
  String? get errorMessage => _errorMessage;

  /// Acesso Admin local para testes e avaliacao sem necessidade de conexao Firebase ativa.
  Future<bool> signInAsLocalAdmin() async {
    _isLocalAdmin = true;
    _isLocked = false;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<bool> signInEmailPassword(String email, String password) async {
    final cleanEmail = email.trim();
    final cleanPass = password.trim();

    // Bypass de conveniencia para Admin Local / Avaliacao
    if (cleanEmail == 'admin@local.com' && cleanPass == 'admin123') {
      return await signInAsLocalAdmin();
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      await _firebaseAuthService.signInWithEmailPassword(cleanEmail, cleanPass);
      _isLocalAdmin = false;
      _isLocked = false;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerEmailPassword(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _firebaseAuthService.registerWithEmailPassword(email, password);
      _isLocalAdmin = false;
      _isLocked = false;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final cred = await _firebaseAuthService.signInWithGoogle();
      _setLoading(false);
      if (cred != null) {
        _isLocalAdmin = false;
        _isLocked = false;
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> unlockWithBiometrics() async {
    final success = await _localAuthService.authenticateWithBiometrics();
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> unlockWithPin(String pin) async {
    if (_isLocalAdmin && (pin == '1234' || pin == '0000')) {
      _isLocked = false;
      notifyListeners();
      return true;
    }

    final valid = await _localAuthService.verifyPin(pin);
    if (valid) {
      _isLocked = false;
      notifyListeners();
    }
    return valid;
  }

  void lockApp() {
    _isLocked = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLocalAdmin = false;
    await _firebaseAuthService.signOut();
    _isLocked = true;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
