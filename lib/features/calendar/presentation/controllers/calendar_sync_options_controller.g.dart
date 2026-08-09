// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_sync_options_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarSyncOptionsController)
final calendarSyncOptionsControllerProvider =
    CalendarSyncOptionsControllerProvider._();

final class CalendarSyncOptionsControllerProvider
    extends
        $NotifierProvider<CalendarSyncOptionsController, CalendarSyncOptions> {
  CalendarSyncOptionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarSyncOptionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarSyncOptionsControllerHash();

  @$internal
  @override
  CalendarSyncOptionsController create() => CalendarSyncOptionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarSyncOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarSyncOptions>(value),
    );
  }
}

String _$calendarSyncOptionsControllerHash() =>
    r'584031306571ffea45776379fd59f99312b221ca';

abstract class _$CalendarSyncOptionsController
    extends $Notifier<CalendarSyncOptions> {
  CalendarSyncOptions build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CalendarSyncOptions, CalendarSyncOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarSyncOptions, CalendarSyncOptions>,
              CalendarSyncOptions,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
