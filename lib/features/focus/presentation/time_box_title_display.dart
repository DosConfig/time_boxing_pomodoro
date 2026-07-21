import '../domain/entities/pomodoro.dart';

String displayTimeBoxTitle(TimeBox box) {
  return box.title;
}

String displayPomodoroTimeBoxTitle(Pomodoro pomodoro) {
  return pomodoro.liveActivityTimeBoxTitle;
}
