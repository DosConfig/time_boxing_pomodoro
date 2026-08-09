import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_shell_controller.g.dart';

@riverpod
class AppShellController extends _$AppShellController {
  @override
  int build() => 0;

  void selectTab(int index) {
    state = index;
  }
}
