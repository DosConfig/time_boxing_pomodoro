import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';
import 'package:time_boxing_pomodoro/shared/legal/legal_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:time_boxing_pomodoro/features/auth/presentation/controllers/auth_controller.dart';
import '../../auth/domain/entities/auth_session.dart';
import '../../auth/presentation/widgets/auth_provider_buttons.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import '../../onboarding/presentation/onboarding_screen.dart'
    show formatClock, normalizeAwakeRange;
import 'package:time_boxing_pomodoro/features/settings/presentation/controllers/awake_window_draft_controller.dart';
import 'package:time_boxing_pomodoro/features/settings/presentation/controllers/app_preferences_controller.dart';
import '../domain/entities/app_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final authSession = ref.watch(authControllerProvider);
    final authActionLoading = ref.watch(authActionControllerProvider);
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
                    _TimeSlotIntervalSectionCard(
                      interval: preferences.timeSlotInterval,
                      onChanged: (interval) {
                        ref
                            .read(appPreferencesControllerProvider.notifier)
                            .setTimeSlotInterval(interval);
                      },
                    ),
                    const SizedBox(height: 14),
                    _LanguageSectionCard(
                      localeCode: preferences.localeCode,
                      onChanged: (localeCode) {
                        ref
                            .read(appPreferencesControllerProvider.notifier)
                            .setLocaleCode(localeCode);
                      },
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
                            label: l10n.liveTrackingTitle,
                            description: l10n.liveTrackingDescription,
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
                            description: l10n.soundDescription,
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
                      authActionLoading: authActionLoading,
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
                      onSignInWithGoogle: () async {
                        final session = await ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle();
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
                        await notifier.flushPendingPlanWrites();
                        await notifier.clearLocalPlanForSignOut();
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                      },
                      onDeleteAccount: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return const _DeleteAccountDialog();
                          },
                        );
                        if (confirmed != true) {
                          return;
                        }

                        await notifier.flushPendingPlanWrites();
                        await notifier.clearLocalPlanForSignOut();
                        final deleted = await ref
                            .read(authControllerProvider.notifier)
                            .deleteAccount();
                        if (!deleted) {
                          await notifier.persistCurrentPlan();
                        }
                        if (!context.mounted) {
                          return;
                        }
                        if (!deleted) {
                          _showSettingsSnack(
                            context,
                            context.l10n.accountDeleteFailed,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const _LegalSectionCard(),
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
                      max: AppPreferencesController.maximumAwakeEndMinutes
                          .toDouble(),
                      divisions: 56,
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
                        minimumSize: const Size.fromHeight(50),
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
  final bool authActionLoading;
  final Future<void> Function() onSignInWithApple;
  final Future<void> Function() onSignInWithGoogle;
  final Future<void> Function() onSignOut;
  final Future<void> Function() onDeleteAccount;

  const _AccountSectionCard({
    required this.authSession,
    required this.authActionLoading,
    required this.onSignInWithApple,
    required this.onSignInWithGoogle,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final loading = authSession.isLoading || authActionLoading;
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
            _SignedInAccount(
              session: session,
              onSignOut: onSignOut,
              onDeleteAccount: onDeleteAccount,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppleSignInBrandButton(
                  label: context.l10n.signInWithAppleAction,
                  enabled: true,
                  onPressed: onSignInWithApple,
                ),
                const SizedBox(height: 10),
                GoogleSignInBrandButton(
                  label: context.l10n.signInWithGoogleAction,
                  enabled: true,
                  onPressed: onSignInWithGoogle,
                ),
              ],
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
  final Future<void> Function() onDeleteAccount;

  const _SignedInAccount({
    required this.session,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = session.displayName.trim();
    final email = session.email.trim();
    final isAppleRelay = email.toLowerCase().endsWith(
      '@privaterelay.appleid.com',
    );
    final label = displayName.isNotEmpty
        ? displayName
        : email.isNotEmpty && !isAppleRelay
        ? email
        : session.providerId == 'apple.com'
        ? context.l10n.appleAccountConnected
        : session.providerId == 'google.com'
        ? context.l10n.googleAccountConnected
        : context.l10n.accountConnected;

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
        const SizedBox(height: 8),
        TextButton(
          onPressed: onDeleteAccount,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.62),
            minimumSize: const Size.fromHeight(42),
          ),
          child: Text(
            context.l10n.deleteAccountAction,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TimeSlotIntervalSectionCard extends StatelessWidget {
  final TimeSlotInterval interval;
  final ValueChanged<TimeSlotInterval> onChanged;

  const _TimeSlotIntervalSectionCard({
    required this.interval,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.timeSlotIntervalTitle,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.timeSlotIntervalDescription,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TimeSlotInterval>(
            segments: [
              ButtonSegment(
                value: TimeSlotInterval.fifteenMinutes,
                label: Text(context.l10n.timeSlot15Minutes),
              ),
              ButtonSegment(
                value: TimeSlotInterval.thirtyMinutes,
                label: Text(context.l10n.timeSlot30Minutes),
              ),
              ButtonSegment(
                value: TimeSlotInterval.oneHour,
                label: Text(context.l10n.timeSlot1Hour),
              ),
            ],
            selected: {interval},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                onChanged(selection.first);
              }
            },
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFF080808)
                    : const Color(0xFFF6F3EC);
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFFF6F3EC)
                    : Colors.transparent;
              }),
              side: WidgetStatePropertyAll(
                BorderSide(color: Colors.white.withValues(alpha: 0.18)),
              ),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSectionCard extends StatelessWidget {
  final String localeCode;
  final ValueChanged<String> onChanged;

  const _LanguageSectionCard({
    required this.localeCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.languageTitle,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _LanguageLabel.resolve(context, localeCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: context.l10n.languageTitle,
            initialValue: localeCode,
            onSelected: onChanged,
            icon: const Icon(Icons.language_rounded),
            itemBuilder: (context) {
              return _LanguageLabel.codes.map((code) {
                return PopupMenuItem<String>(
                  value: code,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: code == localeCode
                            ? const Icon(Icons.check_rounded, size: 18)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_LanguageLabel.resolve(context, code)),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }
}

abstract final class _LanguageLabel {
  static const codes = <String>['', 'ko', 'en', 'ja', 'zh', 'es', 'fr', 'de'];

  static String resolve(BuildContext context, String code) {
    return switch (code) {
      'ko' => context.l10n.languageKorean,
      'en' => context.l10n.languageEnglish,
      'ja' => context.l10n.languageJapanese,
      'zh' => context.l10n.languageChinese,
      'es' => context.l10n.languageSpanish,
      'fr' => context.l10n.languageFrench,
      'de' => context.l10n.languageGerman,
      _ => context.l10n.languageSystem,
    };
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.deleteAccountTitle),
      content: Text(context.l10n.deleteAccountBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.deleteAction),
        ),
      ],
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.legalTitle,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          _LegalLinkTile(
            label: context.l10n.privacyPolicyAction,
            uri: LegalLinks.privacy,
          ),
          _LegalLinkTile(
            label: context.l10n.termsAction,
            uri: LegalLinks.terms,
          ),
          _LegalLinkTile(
            label: context.l10n.supportAction,
            uri: LegalLinks.support,
          ),
        ],
      ),
    );
  }
}

class _LegalLinkTile extends StatelessWidget {
  final String label;
  final Uri uri;

  const _LegalLinkTile({required this.label, required this.uri});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          Icons.open_in_new_rounded,
          color: Colors.white.withValues(alpha: 0.44),
          size: 18,
        ),
        onTap: () async {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!launched && context.mounted) {
            _showSettingsSnack(context, context.l10n.linkOpenFailed);
          }
        },
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsSwitch({
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile.adaptive(
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
        subtitle: description == null
            ? null
            : Text(
                description!,
                style: TextStyle(
                  color: onChanged == null
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.44),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.24,
                ),
              ),
        value: value,
        activeTrackColor: const Color(0xFFF6F3EC),
        activeThumbColor: const Color(0xFF0A0A0A),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
        inactiveThumbColor: const Color(0xFFF6F3EC),
        onChanged: onChanged,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.055),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
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
