// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_ui_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayClock)
final todayClockProvider = TodayClockProvider._();

final class TodayClockProvider extends $NotifierProvider<TodayClock, DateTime> {
  TodayClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayClockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayClockHash();

  @$internal
  @override
  TodayClock create() => TodayClock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$todayClockHash() => r'e341eb2172db1552d60032f7680ce5138634b7ed';

abstract class _$TodayClock extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TodayTimeBoxDragController)
final todayTimeBoxDragControllerProvider =
    TodayTimeBoxDragControllerProvider._();

final class TodayTimeBoxDragControllerProvider
    extends $NotifierProvider<TodayTimeBoxDragController, bool> {
  TodayTimeBoxDragControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTimeBoxDragControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTimeBoxDragControllerHash();

  @$internal
  @override
  TodayTimeBoxDragController create() => TodayTimeBoxDragController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$todayTimeBoxDragControllerHash() =>
    r'4d8f7d09e4b6f4b895f0a8d7017494398b9ad88f';

abstract class _$TodayTimeBoxDragController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
