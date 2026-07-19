import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_draft_controller.g.dart';

typedef AwakeWindowDraft = ({int startMinutes, int endMinutes});

@riverpod
class OnboardingAwakeWindowDraft extends _$OnboardingAwakeWindowDraft {
  @override
  AwakeWindowDraft? build() => null;

  void setWindow(int startMinutes, int endMinutes) {
    state = (startMinutes: startMinutes, endMinutes: endMinutes);
  }
}
