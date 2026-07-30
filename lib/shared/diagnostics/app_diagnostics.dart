import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

const _forceDiagnostics = bool.fromEnvironment('ENABLE_DIAGNOSTICS');

/// Crash reports must describe app state without copying user content.
///
/// Callers should only pass small, non-identifying values such as enum names,
/// counts, or booleans. In particular, do not pass timebox titles, email
/// addresses, authentication tokens, or Live Activity push tokens.
abstract interface class AppDiagnostics {
  bool get isCollectionEnabled;

  List<NavigatorObserver> get navigatorObservers;

  Future<void> setContext(String key, Object value);

  Future<void> breadcrumb(
    String event, {
    Map<String, Object> attributes = const {},
    bool recordAnalyticsEvent = true,
  });

  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    Map<String, Object> attributes = const {},
  });

  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  });

  Future<void> recordFlutterFatal(FlutterErrorDetails details);
}

/// Used by unit/widget tests and as a safe fallback if Firebase cannot start.
class NoopAppDiagnostics implements AppDiagnostics {
  const NoopAppDiagnostics();

  @override
  bool get isCollectionEnabled => false;

  @override
  List<NavigatorObserver> get navigatorObservers => const [];

  @override
  Future<void> breadcrumb(
    String event, {
    Map<String, Object> attributes = const {},
    bool recordAnalyticsEvent = true,
  }) async {}

  @override
  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) async {}

  @override
  Future<void> recordFlutterFatal(FlutterErrorDetails details) async {}

  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    Map<String, Object> attributes = const {},
  }) async {}

  @override
  Future<void> setContext(String key, Object value) async {}
}

class FirebaseAppDiagnostics implements AppDiagnostics {
  FirebaseAppDiagnostics({
    required FirebaseCrashlytics crashlytics,
    required FirebaseAnalytics analytics,
    required this.isCollectionEnabled,
  }) : _crashlytics = crashlytics,
       _analytics = analytics;

  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalytics _analytics;

  @override
  final bool isCollectionEnabled;

  @override
  late final List<NavigatorObserver> navigatorObservers = isCollectionEnabled
      ? [FirebaseAnalyticsObserver(analytics: _analytics)]
      : const [];

  @override
  Future<void> setContext(String key, Object value) async {
    if (!isCollectionEnabled) return;
    await _bestEffort(() => _crashlytics.setCustomKey(key, value));
  }

  @override
  Future<void> breadcrumb(
    String event, {
    Map<String, Object> attributes = const {},
    bool recordAnalyticsEvent = true,
  }) async {
    if (!isCollectionEnabled) return;

    final detail = attributes.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(' ');
    await _bestEffort(
      () => _crashlytics.log(detail.isEmpty ? event : '$event $detail'),
    );
    for (final entry in attributes.entries) {
      await setContext(entry.key, entry.value);
    }

    if (recordAnalyticsEvent) {
      await _bestEffort(
        () => _analytics.logEvent(name: event, parameters: attributes),
      );
    }
  }

  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    Map<String, Object> attributes = const {},
  }) async {
    if (!isCollectionEnabled) return;
    for (final entry in attributes.entries) {
      await setContext(entry.key, entry.value);
    }
    await _bestEffort(
      () => _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      ),
    );
  }

  @override
  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) async {
    if (!isCollectionEnabled) return;
    await _bestEffort(
      () => _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: true,
      ),
    );
  }

  @override
  Future<void> recordFlutterFatal(FlutterErrorDetails details) async {
    if (!isCollectionEnabled) return;
    await _bestEffort(() => _crashlytics.recordFlutterFatalError(details));
  }

  Future<void> _bestEffort(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (_) {
      // Diagnostics must never become a new app failure or recurse into itself.
    }
  }
}

final appDiagnosticsProvider = Provider<AppDiagnostics>(
  (ref) => const NoopAppDiagnostics(),
);

/// Initializes Firebase once and installs a release-safe diagnostics policy.
///
/// Debug/profile builds do not upload diagnostics unless explicitly launched
/// with `--dart-define=ENABLE_DIAGNOSTICS=true`.
Future<AppDiagnostics> initializeAppDiagnostics() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final enabled = kReleaseMode || _forceDiagnostics;
    final crashlytics = FirebaseCrashlytics.instance;
    final analytics = FirebaseAnalytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(enabled);
    try {
      await analytics.setAnalyticsCollectionEnabled(enabled);
      await analytics.setConsent(
        analyticsStorageConsentGranted: enabled,
        adStorageConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false,
        adUserDataConsentGranted: false,
      );
    } catch (_) {
      // Crash reporting remains available if Analytics setup is unavailable.
    }

    // Do not associate Crashlytics reports with an account identifier.
    await crashlytics.setUserIdentifier('');

    final diagnostics = FirebaseAppDiagnostics(
      crashlytics: crashlytics,
      analytics: analytics,
      isCollectionEnabled: enabled,
    );
    await diagnostics.setContext('diagnostics_enabled', enabled);
    return diagnostics;
  } catch (error, stackTrace) {
    debugPrint('Diagnostics initialization skipped: $error\n$stackTrace');
    return const NoopAppDiagnostics();
  }
}

void installGlobalErrorHandlers(AppDiagnostics diagnostics) {
  FlutterError.onError = (details) {
    if (diagnostics.isCollectionEnabled) {
      // recordFlutterFatalError also calls FlutterError.presentError.
      unawaited(diagnostics.recordFlutterFatal(details));
    } else {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    if (!diagnostics.isCollectionEnabled) {
      return false;
    }
    unawaited(
      diagnostics.recordFatal(
        error,
        stackTrace,
        reason: 'uncaught_platform_error',
      ),
    );
    return true;
  };
}

class AppLifecycleDiagnostics extends StatefulWidget {
  const AppLifecycleDiagnostics({
    required this.diagnostics,
    required this.child,
    super.key,
  });

  final AppDiagnostics diagnostics;
  final Widget child;

  @override
  State<AppLifecycleDiagnostics> createState() =>
      _AppLifecycleDiagnosticsState();
}

class _AppLifecycleDiagnosticsState extends State<AppLifecycleDiagnostics>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(widget.diagnostics.setContext('app_lifecycle', state.name));
    unawaited(
      widget.diagnostics.breadcrumb(
        'app_lifecycle_changed',
        attributes: {'lifecycle_state': state.name},
        recordAnalyticsEvent: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
