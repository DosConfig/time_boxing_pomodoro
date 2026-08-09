import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'awake_window_draft_controller.g.dart';

typedef SettingsAwakeWindowDraft = ({int startMinutes, int endMinutes});

@riverpod
class SettingsAwakeWindowDraftController
    extends _$SettingsAwakeWindowDraftController {
  @override
  SettingsAwakeWindowDraft? build() => null;

  void setWindow(int startMinutes, int endMinutes) {
    state = (startMinutes: startMinutes, endMinutes: endMinutes);
  }
}
