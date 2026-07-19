import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_method_channel/l10n/l10n.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../focus/application/pomodoro_controller.dart';
import '../../onboarding/presentation/onboarding_screen.dart'
    show formatClock, normalizeAwakeRange;
import '../application/awake_window_draft_controller.dart';
import '../application/app_preferences_controller.dart';
import '../domain/entities/app_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final authSession = ref.watch(authControllerProvider);
    final preferences = ref.watch(appPreferencesControllerProvider);
    final notifier = ref.read(pomodoroControllerProvider.notifier);

    return SafeArea(
      child: ScrollConfiguration(
        behavior: const _SettingsScrollBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.settingsTitle,
                      style: TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.awakeWindowTitle,
                            style: TextStyle(
                              color: Color(0xFFF6F3EC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${formatClock(preferences.awakeStartMinutes)} - ${formatClock(preferences.awakeEndMinutes)}',
                                  style: const TextStyle(
                                    color: Color(0xFFF6F3EC),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _openAwakeWindowSheet(
                                  context,
                                  ref,
                                  preferences,
                                ),
                                child: Text(
                                  l10n.editAction,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.executionTitle,
                            style: TextStyle(
                              color: Color(0xFFF6F3EC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _SettingsSwitch(
                            label: l10n.autoStartNextTimeBox,
                            value: pomodoro.autoStartFocus,
                            onChanged: notifier.setAutoStartFocus,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.alertsTitle,
                            style: TextStyle(
                              color: Color(0xFFF6F3EC),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _SettingsSwitch(
                            label: l10n.localAlerts,
                            value: pomodoro.notificationsEnabled,
                            onChanged: notifier.setNotificationsEnabled,
                          ),
                          _SettingsSwitch(
                            label: l10n.soundLabel,
                            value: pomodoro.soundEnabled,
                            onChanged: pomodoro.notificationsEnabled
                                ? notifier.setSoundEnabled
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _AccountSectionCard(
                      authSession: authSession,
                      onSignInWithApple: () async {
                        final session = await ref
                            .read(authControllerProvider.notifier)
                            .signInWithApple();
                        if (!context.mounted) {
                          return;
                        }
                        if (!session.isConfigured) {
                          _showSettingsSnack(
                            context,
                            context.l10n.firebaseSetupRequired,
                          );
                        } else if (!session.isSignedIn) {
                          _showSettingsSnack(
                            context,
                            context.l10n.authSignInFailed,
                          );
                        }
                      },
                      onSignOut: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAwakeWindowSheet(
    BuildContext context,
    WidgetRef ref,
    AppPreferences preferences,
  ) {
    ref
        .read(settingsAwakeWindowDraftControllerProvider.notifier)
        .setWindow(preferences.awakeStartMinutes, preferences.awakeEndMinutes);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final draft = ref.watch(settingsAwakeWindowDraftControllerProvider);
            final range = RangeValues(
              (draft?.startMinutes ?? preferences.awakeStartMinutes).toDouble(),
              (draft?.endMinutes ?? preferences.awakeEndMinutes).toDouble(),
            );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.awakeWindowTitle,
                      style: TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${formatClock(range.start.round())} - ${formatClock(range.end.round())}',
                      style: const TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      values: range,
                      min: 0,
                      max: 24 * 60,
                      divisions: 48,
                      activeColor: const Color(0xFFF6F3EC),
                      inactiveColor: Colors.white.withValues(alpha: 0.16),
                      labels: RangeLabels(
                        formatClock(range.start.round()),
                        formatClock(range.end.round()),
                      ),
                      onChanged: (next) {
                        final normalized = normalizeAwakeRange(next);
                        ref
                            .read(
                              settingsAwakeWindowDraftControllerProvider
                                  .notifier,
                            )
                            .setWindow(
                              normalized.start.round(),
                              normalized.end.round(),
                            );
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await ref
                            .read(appPreferencesControllerProvider.notifier)
                            .saveAwakeWindow(
                              range.start.round(),
                              range.end.round(),
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF6F3EC),
                        foregroundColor: const Color(0xFF080808),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: Text(
                        context.l10n.saveAction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void _showSettingsSnack(BuildContext context, String message) {
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

class _AccountSectionCard extends StatelessWidget {
  final AsyncValue<AuthSession> authSession;
  final Future<void> Function() onSignInWithApple;
  final Future<void> Function() onSignOut;

  const _AccountSectionCard({
    required this.authSession,
    required this.onSignInWithApple,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final loading = authSession.isLoading;
    final session = authSession.asData?.value;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.accountTitle,
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (loading)
            const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (session == null || !session.isConfigured)
            _FirebaseSetupMessage()
          else if (session.isSignedIn)
            _SignedInAccount(session: session, onSignOut: onSignOut)
          else
            FilledButton.icon(
              onPressed: onSignInWithApple,
              icon: const Icon(Icons.account_circle_rounded),
              label: Text(
                context.l10n.signInWithAppleAction,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF6F3EC),
                foregroundColor: const Color(0xFF080808),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FirebaseSetupMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.firebaseSetupRequired,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.firebaseSetupDescription,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.54),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedInAccount extends StatelessWidget {
  final AuthSession session;
  final Future<void> Function() onSignOut;

  const _SignedInAccount({required this.session, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final label = session.email.isNotEmpty
        ? session.email
        : session.displayName.isNotEmpty
        ? session.displayName
        : session.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.signedInAs(label),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: onSignOut,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFF6F3EC),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            context.l10n.signOutAction,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          color: onChanged == null
              ? Colors.white.withValues(alpha: 0.34)
              : const Color(0xFFF6F3EC),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: value,
      activeTrackColor: const Color(0xFFF6F3EC),
      activeThumbColor: const Color(0xFF0A0A0A),
      inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
      inactiveThumbColor: const Color(0xFFF6F3EC),
      onChanged: onChanged,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _SettingsScrollBehavior extends MaterialScrollBehavior {
  const _SettingsScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
