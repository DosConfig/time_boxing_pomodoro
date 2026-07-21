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

@riverpod
class TodayTimeBoxResizeDragController
    extends _$TodayTimeBoxResizeDragController {
  @override
  Map<String, double> build() => const {};

  void start(String id) {
    state = {...state, id: 0};
  }

  int consumeSlotDelta(String id, double delta, double slotHeight) {
    final nextDy = (state[id] ?? 0) + delta;
    final slotDelta = (nextDy / slotHeight).truncate();
    state = {...state, id: nextDy - (slotDelta * slotHeight)};
    return slotDelta;
  }

  void end(String id) {
    final nextState = Map<String, double>.from(state)..remove(id);
    state = nextState;
  }
}

@riverpod
class TodayTimeBoxResizeModeController
    extends _$TodayTimeBoxResizeModeController {
  @override
  String build() => '';

  void toggle(String id) {
    state = state == id ? '' : id;
  }

  void activate(String id) {
    state = id;
  }

  void deactivate(String id) {
    if (state == id) {
      state = '';
    }
  }

  void clear() {
    state = '';
  }
}

@riverpod
class TodayTimeBoxActionController extends _$TodayTimeBoxActionController {
  @override
  String build() => '';

  void toggle(String id) {
    state = state == id ? '' : id;
  }

  void activate(String id) {
    state = id;
  }

  void clear() {
    state = '';
  }
}
