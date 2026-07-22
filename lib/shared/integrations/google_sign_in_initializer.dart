import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:time_boxing_pomodoro/firebase_options.dart';

class GoogleSignInInitializer {
  static Future<void>? _initializeFuture;

  const GoogleSignInInitializer._();

  static Future<void> ensureInitialized() async {
    try {
      _initializeFuture ??= GoogleSignIn.instance.initialize(
        clientId: _clientIdForCurrentPlatform(),
      );
      await _initializeFuture;
    } catch (_) {
      _initializeFuture = null;
      rethrow;
    }
  }

  static String? _clientIdForCurrentPlatform() {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => DefaultFirebaseOptions.ios.iosClientId,
      _ => null,
    };
  }
}
