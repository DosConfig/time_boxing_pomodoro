// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingAwakeWindowDraft)
final onboardingAwakeWindowDraftProvider =
    OnboardingAwakeWindowDraftProvider._();

final class OnboardingAwakeWindowDraftProvider
    extends $NotifierProvider<OnboardingAwakeWindowDraft, AwakeWindowDraft?> {
  OnboardingAwakeWindowDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingAwakeWindowDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingAwakeWindowDraftHash();

  @$internal
  @override
  OnboardingAwakeWindowDraft create() => OnboardingAwakeWindowDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AwakeWindowDraft? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AwakeWindowDraft?>(value),
    );
  }
}

String _$onboardingAwakeWindowDraftHash() =>
    r'3a4996e430fbf973fadd833359ab9fc2b198b761';

abstract class _$OnboardingAwakeWindowDraft
    extends $Notifier<AwakeWindowDraft?> {
  AwakeWindowDraft? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AwakeWindowDraft?, AwakeWindowDraft?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AwakeWindowDraft?, AwakeWindowDraft?>,
              AwakeWindowDraft?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
