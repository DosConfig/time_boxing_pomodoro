import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_session.dart';

class FirebaseAuthDataSource {
  Future<AuthSession> currentSession() async {
    final configured = await _ensureConfigured();
    if (!configured) {
      return const AuthSession();
    }
    return _sessionFromUser(FirebaseAuth.instance.currentUser);
  }

  Future<AuthSession> signInWithApple() async {
    final configured = await _ensureConfigured();
    if (!configured) {
      return const AuthSession();
    }

    final provider = AppleAuthProvider();
    final credential = await FirebaseAuth.instance.signInWithProvider(provider);
    return _sessionFromUser(credential.user);
  }

  Future<void> signOut() async {
    final configured = await _ensureConfigured();
    if (!configured) {
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> _ensureConfigured() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    try {
      await Firebase.initializeApp();
      return true;
    } catch (error) {
      debugPrint('Firebase is not configured: $error');
      return false;
    }
  }

  AuthSession _sessionFromUser(User? user) {
    if (user == null) {
      return const AuthSession(isConfigured: true);
    }

    return AuthSession(
      isConfigured: true,
      userId: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }
}
