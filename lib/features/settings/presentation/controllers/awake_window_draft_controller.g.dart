// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'awake_window_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsAwakeWindowDraftController)
final settingsAwakeWindowDraftControllerProvider =
    SettingsAwakeWindowDraftControllerProvider._();

final class SettingsAwakeWindowDraftControllerProvider
    extends
        $NotifierProvider<
          SettingsAwakeWindowDraftController,
          SettingsAwakeWindowDraft?
        > {
  SettingsAwakeWindowDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsAwakeWindowDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$settingsAwakeWindowDraftControllerHash();

  @$internal
  @override
  SettingsAwakeWindowDraftController create() =>
      SettingsAwakeWindowDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsAwakeWindowDraft? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsAwakeWindowDraft?>(value),
    );
  }
}

String _$settingsAwakeWindowDraftControllerHash() =>
    r'9f6fecf2e1645bedfa8701e0f37d51360d767056';

abstract class _$SettingsAwakeWindowDraftController
    extends $Notifier<SettingsAwakeWindowDraft?> {
  SettingsAwakeWindowDraft? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SettingsAwakeWindowDraft?, SettingsAwakeWindowDraft?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SettingsAwakeWindowDraft?, SettingsAwakeWindowDraft?>,
              SettingsAwakeWindowDraft?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
