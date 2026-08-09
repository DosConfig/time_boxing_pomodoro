import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/today/presentation/controllers/today_ui_controller.dart';

void main() {
  test('resize drag consumes movement in exact slot-height steps', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(
      todayTimeBoxResizeDragControllerProvider.notifier,
    );

    controller.start('box');

    expect(controller.consumeSlotDelta('box', 69, 70), 0);
    expect(controller.consumeSlotDelta('box', 1, 70), 1);
    expect(controller.consumeSlotDelta('box', 200, 70), 2);
    expect(controller.consumeSlotDelta('box', 10, 70), 1);
    expect(controller.consumeSlotDelta('box', -70, 70), -1);

    controller.end('box');
    expect(container.read(todayTimeBoxResizeDragControllerProvider), isEmpty);
  });
}
