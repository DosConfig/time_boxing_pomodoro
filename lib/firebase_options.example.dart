// Test-only Firebase options for public CI. Production builds restore the
// ignored, project-specific file through scripts/ci/restore_firebase_config.sh.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web.');
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => ios,
      _ => android,
    };
  }

  static const ios = FirebaseOptions(
    apiKey: 'public-ci-placeholder',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'public-ci-placeholder',
    iosBundleId: 'com.seongwoo.focusmark',
  );

  static const android = FirebaseOptions(
    apiKey: 'public-ci-placeholder',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'public-ci-placeholder',
  );
}
