import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:time_boxing_pomodoro/firebase_options.dart';
import 'package:time_boxing_pomodoro/shared/integrations/google_sign_in_initializer.dart';

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

    try {
      final provider = AppleAuthProvider();
      final credential = await FirebaseAuth.instance.signInWithProvider(
        provider,
      );
      return _sessionFromUser(credential.user);
    } on FirebaseAuthException catch (error) {
      debugPrint('Apple sign-in failed: $error');
      return const AuthSession(isConfigured: true);
    }
  }

  Future<AuthSession> signInWithGoogle() async {
    final configured = await _ensureConfigured();
    if (!configured) {
      return const AuthSession();
    }

    await GoogleSignInInitializer.ensureInitialized();
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      return const AuthSession(isConfigured: true);
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const AuthSession(isConfigured: true);
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      return _sessionFromUser(userCredential.user);
    } on GoogleSignInException catch (error) {
      debugPrint('Google sign-in failed: $error');
      return const AuthSession(isConfigured: true);
    } on FirebaseAuthException catch (error) {
      debugPrint('Google Firebase sign-in failed: $error');
      return const AuthSession(isConfigured: true);
    }
  }

  Future<void> signOut() async {
    final configured = await _ensureConfigured();
    if (!configured) {
      return;
    }
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignInInitializer.ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      debugPrint('Google sign-out skipped: $error');
    }
  }

  Future<bool> deleteAccount() async {
    final configured = await _ensureConfigured();
    if (!configured) {
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final reauthenticated = await _reauthenticateForDeletion(user);
      if (!reauthenticated) {
        return false;
      }
      await _deleteUserPlanData(user.uid);
      await user.delete();
      await _clearProviderSession();
      return true;
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase account deletion failed: $error');
      return false;
    } catch (error) {
      debugPrint('Account deletion failed: $error');
      return false;
    }
  }

  Future<void> _clearProviderSession() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      debugPrint('Firebase sign-out after account deletion skipped: $error');
    }

    try {
      await GoogleSignInInitializer.ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      debugPrint('Google sign-out after account deletion skipped: $error');
    }
  }

  Future<bool> _reauthenticateForDeletion(User user) async {
    final providerIds = user.providerData
        .map((provider) => provider.providerId)
        .toSet();

    try {
      if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) {
        await GoogleSignInInitializer.ensureInitialized();
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          return false;
        }
        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
        return true;
      }

      if (providerIds.contains(AppleAuthProvider.PROVIDER_ID)) {
        await user.reauthenticateWithProvider(AppleAuthProvider());
        return true;
      }
    } on GoogleSignInException catch (error) {
      debugPrint('Google reauthentication canceled or failed: $error');
      return false;
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase reauthentication failed: $error');
      return false;
    }

    debugPrint('Account deletion is unavailable for this sign-in provider.');
    return false;
  }

  Future<void> _deleteUserPlanData(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final userDocument = firestore.collection('users').doc(userId);
    final days = await userDocument.collection('days').get();
    var batch = firestore.batch();
    var operationCount = 0;

    for (final day in days.docs) {
      batch.delete(day.reference);
      operationCount += 1;
      if (operationCount == 450) {
        await batch.commit();
        batch = firestore.batch();
        operationCount = 0;
      }
    }

    batch.delete(userDocument);
    await batch.commit();
  }

  Future<bool> _ensureConfigured() async {
    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
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
      providerId: user.providerData.isEmpty
          ? ''
          : user.providerData.first.providerId,
    );
  }
}
