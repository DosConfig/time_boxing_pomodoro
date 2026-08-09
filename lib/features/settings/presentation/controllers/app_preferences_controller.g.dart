// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppPreferencesController)
final appPreferencesControllerProvider = AppPreferencesControllerProvider._();

final class AppPreferencesControllerProvider
    extends $NotifierProvider<AppPreferencesController, AppPreferences> {
  AppPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPreferencesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPreferencesControllerHash();

  @$internal
  @override
  AppPreferencesController create() => AppPreferencesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPreferences>(value),
    );
  }
}

String _$appPreferencesControllerHash() =>
    r'b9c830c0c5369fa8f410cbf1ba10aa92426f2a59';

abstract class _$AppPreferencesController extends $Notifier<AppPreferences> {
  AppPreferences build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppPreferences, AppPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppPreferences, AppPreferences>,
              AppPreferences,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
