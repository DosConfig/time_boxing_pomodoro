import 'package:flutter/material.dart';

/// 앱 공통 스낵바. 화면/시트 어디서든 같은 형태로 짧은 안내를 띄운다.
void showAppSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1600),
    ),
  );
}
