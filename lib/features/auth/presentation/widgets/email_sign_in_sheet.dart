import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import 'package:time_boxing_pomodoro/features/auth/presentation/controllers/auth_controller.dart';

class EmailSignInSheet extends ConsumerStatefulWidget {
  const EmailSignInSheet({super.key});

  @override
  ConsumerState<EmailSignInSheet> createState() => _EmailSignInSheetState();
}

class _EmailSignInSheetState extends ConsumerState<EmailSignInSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _signInFailed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _signInFailed = false);
    HapticFeedback.mediumImpact();
    final session = await ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) {
      return;
    }
    if (session.isSignedIn) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _signInFailed = true);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authActionControllerProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EmailSheetHeader(title: context.l10n.emailSignInTitle),
                const SizedBox(height: 22),
                TextFormField(
                  key: const ValueKey('emailSignInEmailField'),
                  controller: _emailController,
                  enabled: !loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    return email.contains('@')
                        ? null
                        : context.l10n.emailSignInValidation;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('emailSignInPasswordField'),
                  controller: _passwordController,
                  enabled: !loading,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: context.l10n.passwordLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? context.l10n.showPasswordAction
                          : context.l10n.hidePasswordAction,
                      onPressed: loading
                          ? null
                          : () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => (value?.isNotEmpty ?? false)
                      ? null
                      : context.l10n.passwordSignInValidation,
                ),
                if (_signInFailed) ...[
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.emailSignInFailed,
                    key: const ValueKey('emailSignInError'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  key: const ValueKey('emailSignInSubmitButton'),
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.signInAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailSheetHeader extends StatelessWidget {
  final String title;

  const _EmailSheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
