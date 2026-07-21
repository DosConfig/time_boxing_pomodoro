// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarExportController)
final calendarExportControllerProvider = CalendarExportControllerFamily._();

final class CalendarExportControllerProvider
    extends
        $AsyncNotifierProvider<
          CalendarExportController,
          CalendarExportResult?
        > {
  CalendarExportControllerProvider._({
    required CalendarExportControllerFamily super.from,
    required CalendarProvider super.argument,
  }) : super(
         retry: null,
         name: r'calendarExportControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarExportControllerHash();

  @override
  String toString() {
    return r'calendarExportControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CalendarExportController create() => CalendarExportController();

  @override
  bool operator ==(Object other) {
    return other is CalendarExportControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarExportControllerHash() =>
    r'a80e1a0f19abb41aad231b57a82a3e919c6817a9';

final class CalendarExportControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarExportController,
          AsyncValue<CalendarExportResult?>,
          CalendarExportResult?,
          FutureOr<CalendarExportResult?>,
          CalendarProvider
        > {
  CalendarExportControllerFamily._()
    : super(
        retry: null,
        name: r'calendarExportControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarExportControllerProvider call(CalendarProvider provider) =>
      CalendarExportControllerProvider._(argument: provider, from: this);

  @override
  String toString() => r'calendarExportControllerProvider';
}

abstract class _$CalendarExportController
    extends $AsyncNotifier<CalendarExportResult?> {
  late final _$args = ref.$arg as CalendarProvider;
  CalendarProvider get provider => _$args;

  FutureOr<CalendarExportResult?> build(CalendarProvider provider);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CalendarExportResult?>, CalendarExportResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CalendarExportResult?>,
                CalendarExportResult?
              >,
              AsyncValue<CalendarExportResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
