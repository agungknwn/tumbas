import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isDeviceSuported = await _auth.isDeviceSupported();
    return canCheck && isDeviceSuported;
  }

  static Future<bool> authenticate() async {
    return await _auth.authenticate(
      localizedReason: 'Authenticate to login',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }
}
