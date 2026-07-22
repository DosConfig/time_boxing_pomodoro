import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';
import 'package:time_boxing_pomodoro/shared/presentation/widgets/focus_mark_motion.dart';

import '../application/auth_controller.dart';
import '../domain/entities/auth_session.dart';
import 'widgets/auth_provider_buttons.dart';
import 'widgets/email_sign_in_sheet.dart';

class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authActionLoading = ref.watch(authActionControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            final heroHeight = compact ? 168.0 : 226.0;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, compact ? 22 : 30, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthHero(height: heroHeight),
                      SizedBox(height: compact ? 24 : 34),
                      _AuthBrandCopy(
                        appName: context.l10n.appName,
                        eyebrow: context.l10n.introBrandEyebrow,
                        body: context.l10n.introBrandBody,
                      ),
                      SizedBox(height: compact ? 26 : 36),
                      _AuthActions(
                        loading: authActionLoading,
                        onSignInWithApple: () async {
                          HapticFeedback.mediumImpact();
                          final session = await ref
                              .read(authControllerProvider.notifier)
                              .signInWithApple();
                          if (context.mounted) {
                            showAuthGateSnackIfNeeded(context, session);
                          }
                        },
                        onSignInWithGoogle: () async {
                          HapticFeedback.mediumImpact();
                          final session = await ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle();
                          if (context.mounted) {
                            showAuthGateSnackIfNeeded(context, session);
                          }
                        },
                        onSignInWithEmail: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: const Color(0xFF111111),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            builder: (context) => const EmailSignInSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void showAuthGateSnackIfNeeded(BuildContext context, AuthSession session) {
  if (session.isSignedIn) {
    return;
  }

  final message = session.isConfigured
      ? context.l10n.authSignInFailed
      : context.l10n.firebaseSetupRequired;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1800),
    ),
  );
}

class _AuthHero extends StatelessWidget {
  final double height;

  const _AuthHero({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: const FocusMarkMotion());
  }
}

class _AuthBrandCopy extends StatelessWidget {
  final String appName;
  final String eyebrow;
  final String body;

  const _AuthBrandCopy({
    required this.appName,
    required this.eyebrow,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          eyebrow,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.52),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          body,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.56),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.34,
          ),
        ),
      ],
    );
  }
}

class _AuthActions extends StatelessWidget {
  final bool loading;
  final Future<void> Function() onSignInWithApple;
  final Future<void> Function() onSignInWithGoogle;
  final VoidCallback onSignInWithEmail;

  const _AuthActions({
    required this.loading,
    required this.onSignInWithApple,
    required this.onSignInWithGoogle,
    required this.onSignInWithEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppleSignInBrandButton(
              label: context.l10n.signInWithAppleAction,
              enabled: !loading,
              onPressed: onSignInWithApple,
            ),
            const SizedBox(height: 10),
            GoogleSignInBrandButton(
              label: context.l10n.signInWithGoogleAction,
              enabled: !loading,
              onPressed: onSignInWithGoogle,
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const ValueKey('emailSignInOpenButton'),
              onPressed: loading ? null : onSignInWithEmail,
              child: Text(context.l10n.signInWithEmailAction),
            ),
          ],
        ),
      ),
    );
  }
}
