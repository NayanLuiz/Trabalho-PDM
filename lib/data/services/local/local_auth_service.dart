import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _pinKey = 'user_app_pin';
  static const _biometricsEnabledKey = 'biometrics_enabled';

  Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Autentique-se para acessar o controle financeiro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin != null && storedPin == enteredPin;
  }

  Future<bool> hasPinConfigured() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _secureStorage.write(key: _biometricsEnabledKey, value: enabled.toString());
  }

  Future<bool> isBiometricsEnabled() async {
    final val = await _secureStorage.read(key: _biometricsEnabledKey);
    return val == 'true';
  }
}

