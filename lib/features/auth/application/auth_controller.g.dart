// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseAuthDataSource)
final firebaseAuthDataSourceProvider = FirebaseAuthDataSourceProvider._();

final class FirebaseAuthDataSourceProvider
    extends
        $FunctionalProvider<
          FirebaseAuthDataSource,
          FirebaseAuthDataSource,
          FirebaseAuthDataSource
        >
    with $Provider<FirebaseAuthDataSource> {
  FirebaseAuthDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthDataSourceHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuthDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseAuthDataSource create(Ref ref) {
    return firebaseAuthDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuthDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuthDataSource>(value),
    );
  }
}

String _$firebaseAuthDataSourceHash() =>
    r'95a0b0edd77b64b9889b799f7f261a1e504f76b6';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'c9694c92ae9f31d333dd757ce9c68d70885c93bb';

@ProviderFor(getAuthSessionUseCase)
final getAuthSessionUseCaseProvider = GetAuthSessionUseCaseProvider._();

final class GetAuthSessionUseCaseProvider
    extends
        $FunctionalProvider<
          GetAuthSessionUseCase,
          GetAuthSessionUseCase,
          GetAuthSessionUseCase
        >
    with $Provider<GetAuthSessionUseCase> {
  GetAuthSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAuthSessionUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAuthSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAuthSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAuthSessionUseCase create(Ref ref) {
    return getAuthSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAuthSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAuthSessionUseCase>(value),
    );
  }
}

String _$getAuthSessionUseCaseHash() =>
    r'7568dfc60d05de74adacacc6062d482cf5eff47a';

@ProviderFor(signInWithAppleUseCase)
final signInWithAppleUseCaseProvider = SignInWithAppleUseCaseProvider._();

final class SignInWithAppleUseCaseProvider
    extends
        $FunctionalProvider<
          SignInWithAppleUseCase,
          SignInWithAppleUseCase,
          SignInWithAppleUseCase
        >
    with $Provider<SignInWithAppleUseCase> {
  SignInWithAppleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithAppleUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithAppleUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithAppleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignInWithAppleUseCase create(Ref ref) {
    return signInWithAppleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithAppleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithAppleUseCase>(value),
    );
  }
}

String _$signInWithAppleUseCaseHash() =>
    r'29cf5a8f0dd51e46ff3bdc2c72c316f555acce6c';

@ProviderFor(signOutUseCase)
final signOutUseCaseProvider = SignOutUseCaseProvider._();

final class SignOutUseCaseProvider
    extends $FunctionalProvider<SignOutUseCase, SignOutUseCase, SignOutUseCase>
    with $Provider<SignOutUseCase> {
  SignOutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignOutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOutUseCase create(Ref ref) {
    return signOutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutUseCase>(value),
    );
  }
}

String _$signOutUseCaseHash() => r'bbd5043050da20a630ca0946e3ddb79fef73eab1';

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthSession> {
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'db5c786f8c375712405c41f9205afa817fe28b41';

abstract class _$AuthController extends $AsyncNotifier<AuthSession> {
  FutureOr<AuthSession> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthSession>, AuthSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthSession>, AuthSession>,
              AsyncValue<AuthSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
