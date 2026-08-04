// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pomodoroClock)
final pomodoroClockProvider = PomodoroClockProvider._();

final class PomodoroClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  PomodoroClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pomodoroClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pomodoroClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return pomodoroClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$pomodoroClockHash() => r'1325e744f3aff7a91334602b700a6c8b56241e49';

@ProviderFor(dailyPlanHistory)
final dailyPlanHistoryProvider = DailyPlanHistoryFamily._();

final class DailyPlanHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyPlanSummary>>,
          List<DailyPlanSummary>,
          FutureOr<List<DailyPlanSummary>>
        >
    with
        $FutureModifier<List<DailyPlanSummary>>,
        $FutureProvider<List<DailyPlanSummary>> {
  DailyPlanHistoryProvider._({
    required DailyPlanHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'dailyPlanHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyPlanHistoryHash();

  @override
  String toString() {
    return r'dailyPlanHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DailyPlanSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DailyPlanSummary>> create(Ref ref) {
    final argument = this.argument as int;
    return dailyPlanHistory(ref, days: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyPlanHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyPlanHistoryHash() => r'616265880f08a69a3ee56240dd2dce8ccc654e1e';

final class DailyPlanHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DailyPlanSummary>>, int> {
  DailyPlanHistoryFamily._()
    : super(
        retry: null,
        name: r'dailyPlanHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DailyPlanHistoryProvider call({int days = 7}) =>
      DailyPlanHistoryProvider._(argument: days, from: this);

  @override
  String toString() => r'dailyPlanHistoryProvider';
}

/// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 원문. 과거 기록 열람 UI가 사용한다.
/// doc: docs/architecture/DATA_LIFECYCLE.md

@ProviderFor(planForDate)
final planForDateProvider = PlanForDateFamily._();

/// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 원문. 과거 기록 열람 UI가 사용한다.
/// doc: docs/architecture/DATA_LIFECYCLE.md

final class PlanForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<Pomodoro?>,
          Pomodoro?,
          FutureOr<Pomodoro?>
        >
    with $FutureModifier<Pomodoro?>, $FutureProvider<Pomodoro?> {
  /// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 원문. 과거 기록 열람 UI가 사용한다.
  /// doc: docs/architecture/DATA_LIFECYCLE.md
  PlanForDateProvider._({
    required PlanForDateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'planForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planForDateHash();

  @override
  String toString() {
    return r'planForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Pomodoro?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Pomodoro?> create(Ref ref) {
    final argument = this.argument as String;
    return planForDate(ref, dateKey: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planForDateHash() => r'28432e486924ea75f16c0408d0096350b5803e0a';

/// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 원문. 과거 기록 열람 UI가 사용한다.
/// doc: docs/architecture/DATA_LIFECYCLE.md

final class PlanForDateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Pomodoro?>, String> {
  PlanForDateFamily._()
    : super(
        retry: null,
        name: r'planForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 원문. 과거 기록 열람 UI가 사용한다.
  /// doc: docs/architecture/DATA_LIFECYCLE.md

  PlanForDateProvider call({required String dateKey}) =>
      PlanForDateProvider._(argument: dateKey, from: this);

  @override
  String toString() => r'planForDateProvider';
}

@ProviderFor(PomodoroController)
final pomodoroControllerProvider = PomodoroControllerProvider._();

final class PomodoroControllerProvider
    extends $NotifierProvider<PomodoroController, Pomodoro> {
  PomodoroControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pomodoroControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pomodoroControllerHash();

  @$internal
  @override
  PomodoroController create() => PomodoroController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Pomodoro value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Pomodoro>(value),
    );
  }
}

String _$pomodoroControllerHash() =>
    r'4c02590615ef60c6784819682ea3897882a36f0d';

abstract class _$PomodoroController extends $Notifier<Pomodoro> {
  Pomodoro build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Pomodoro, Pomodoro>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Pomodoro, Pomodoro>,
              Pomodoro,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
