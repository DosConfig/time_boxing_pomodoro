import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';

@freezed
abstract class AuthSession with _$AuthSession {
  const AuthSession._();

  const factory AuthSession({
    @Default(false) bool isConfigured,
    @Default('') String userId,
    @Default('') String email,
    @Default('') String displayName,
  }) = _AuthSession;

  bool get isSignedIn => userId.isNotEmpty;
}
