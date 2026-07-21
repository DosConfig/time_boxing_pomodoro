import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInInitializer {
  static Future<void>? _initializeFuture;

  const GoogleSignInInitializer._();

  static Future<void> ensureInitialized() async {
    try {
      _initializeFuture ??= GoogleSignIn.instance.initialize();
      await _initializeFuture;
    } catch (_) {
      _initializeFuture = null;
      rethrow;
    }
  }
}
