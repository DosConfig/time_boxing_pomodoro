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

@ProviderFor(TodayTimeBoxResizeDragController)
final todayTimeBoxResizeDragControllerProvider =
    TodayTimeBoxResizeDragControllerProvider._();

final class TodayTimeBoxResizeDragControllerProvider
    extends
        $NotifierProvider<
          TodayTimeBoxResizeDragController,
          Map<String, double>
        > {
  TodayTimeBoxResizeDragControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTimeBoxResizeDragControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTimeBoxResizeDragControllerHash();

  @$internal
  @override
  TodayTimeBoxResizeDragController create() =>
      TodayTimeBoxResizeDragController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$todayTimeBoxResizeDragControllerHash() =>
    r'3c989c9c92272d3e99e3434d0fe758a787652ce7';

abstract class _$TodayTimeBoxResizeDragController
    extends $Notifier<Map<String, double>> {
  Map<String, double> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, double>, Map<String, double>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, double>, Map<String, double>>,
              Map<String, double>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TodayTimeBoxResizeModeController)
final todayTimeBoxResizeModeControllerProvider =
    TodayTimeBoxResizeModeControllerProvider._();

final class TodayTimeBoxResizeModeControllerProvider
    extends $NotifierProvider<TodayTimeBoxResizeModeController, String> {
  TodayTimeBoxResizeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTimeBoxResizeModeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTimeBoxResizeModeControllerHash();

  @$internal
  @override
  TodayTimeBoxResizeModeController create() =>
      TodayTimeBoxResizeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$todayTimeBoxResizeModeControllerHash() =>
    r'bd607be60d70d180b61340b91d62d5e24261fc06';

abstract class _$TodayTimeBoxResizeModeController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TodayTimeBoxActionController)
final todayTimeBoxActionControllerProvider =
    TodayTimeBoxActionControllerProvider._();

final class TodayTimeBoxActionControllerProvider
    extends $NotifierProvider<TodayTimeBoxActionController, String> {
  TodayTimeBoxActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTimeBoxActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTimeBoxActionControllerHash();

  @$internal
  @override
  TodayTimeBoxActionController create() => TodayTimeBoxActionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$todayTimeBoxActionControllerHash() =>
    r'5e27590b1a2995dc247753c6d3ee496a65fbbea6';

abstract class _$TodayTimeBoxActionController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
