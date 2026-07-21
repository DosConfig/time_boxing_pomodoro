import 'package:flutter/material.dart';

class AppleSignInBrandButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final Future<void> Function() onPressed;

  const AppleSignInBrandButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthProviderButton(
      label: label,
      enabled: enabled,
      onPressed: onPressed,
      mark: const _AppleBrandMark(),
    );
  }
}

class GoogleSignInBrandButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final Future<void> Function() onPressed;

  const GoogleSignInBrandButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthProviderButton(
      label: label,
      enabled: enabled,
      onPressed: onPressed,
      mark: const _GoogleBrandMark(),
    );
  }
}

class _AuthProviderButton extends StatelessWidget {
  static final _radius = BorderRadius.circular(8);

  final String label;
  final bool enabled;
  final Future<void> Function() onPressed;
  final Widget mark;

  const _AuthProviderButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.mark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : 0.48,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF747775)),
            borderRadius: _radius,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () {
                    onPressed();
                  }
                : null,
            child: SizedBox(
              height: 44,
              child: _AuthProviderButtonContent(label: label, mark: mark),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthProviderButtonContent extends StatelessWidget {
  final String label;
  final Widget mark;

  const _AuthProviderButtonContent({required this.label, required this.mark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Row(
        children: [
          SizedBox(width: 28, child: Center(child: mark)),
          Expanded(
            child: Center(child: _AuthProviderButtonLabel(label: label)),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _AppleBrandMark extends StatelessWidget {
  const _AppleBrandMark();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, color: Color(0xFF1F1F1F), size: 20);
  }
}

class _GoogleBrandMark extends StatelessWidget {
  static const _assetPath = 'assets/auth/google_g_logo.png';

  const _GoogleBrandMark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

class _AuthProviderButtonLabel extends StatelessWidget {
  final String label;

  const _AuthProviderButtonLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF1F1F1F),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0,
      ),
    );
  }
}
