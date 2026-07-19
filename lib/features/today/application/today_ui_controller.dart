import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_ui_controller.g.dart';

@riverpod
class TodayClock extends _$TodayClock {
  Timer? _timer;

  @override
  DateTime build() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      state = DateTime.now();
    });
    ref.onDispose(() => _timer?.cancel());
    return DateTime.now();
  }
}

@riverpod
class TodayTimeBoxDragController extends _$TodayTimeBoxDragController {
  @override
  bool build() => false;

  void begin() {
    state = true;
  }

  void end() {
    state = false;
  }
}
