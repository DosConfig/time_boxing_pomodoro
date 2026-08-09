// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_shell_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppShellController)
final appShellControllerProvider = AppShellControllerProvider._();

final class AppShellControllerProvider
    extends $NotifierProvider<AppShellController, int> {
  AppShellControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appShellControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appShellControllerHash();

  @$internal
  @override
  AppShellController create() => AppShellController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$appShellControllerHash() =>
    r'3f1d7c37482e367d49982bd08e5e21af04538695';

abstract class _$AppShellController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
