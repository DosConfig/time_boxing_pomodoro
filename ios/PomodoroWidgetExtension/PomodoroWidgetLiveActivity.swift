import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct PomodoroWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    // 좁은 leading에는 페이즈 아이콘만 두고,
                    // 제목은 폭이 넓은 bottom 영역에서 최대 2줄로 보여준다.
                    Image(systemName: phaseIcon(context))
                        .foregroundStyle(.white)
                        .font(.caption.weight(.semibold))
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.sessionCount)/\(context.state.sessionGoal)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.center) {
                    timerText(context, size: 28)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentTimeBoxTitle(context))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ProgressView(value: progressValue(context), total: Double(context.attributes.totalDuration))
                            .tint(.white)
                    }
                }
            } compactLeading: {
                Image(systemName: phaseIcon(context))
                    .foregroundStyle(.white)
                    .font(.caption2.weight(.semibold))
            } compactTrailing: {
                timerText(context, size: 11)
            } minimal: {
                Image(systemName: "target")
                    .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private func timerText(_ context: ActivityViewContext<PomodoroActivityAttributes>, size: CGFloat) -> some View {
        if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
            Text(formatTime(seconds: pausedSeconds))
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        } else {
            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func progressValue(_ context: ActivityViewContext<PomodoroActivityAttributes>) -> Double {
        if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
            return Double(pausedSeconds)
        }
        return max(0, context.state.endTime.timeIntervalSinceNow)
    }

    private func phaseTitle(_ context: ActivityViewContext<PomodoroActivityAttributes>) -> String {
        if context.state.status == "paused" {
            return context.state.localizedPausedTitle
        }

        switch context.state.phase {
        case "shortBreak":
            return context.state.localizedShortBreakTitle
        case "longBreak":
            return context.state.localizedLongBreakTitle
        default:
            return context.state.localizedFocusTitle
        }
    }

    private func phaseIcon(_ context: ActivityViewContext<PomodoroActivityAttributes>) -> String {
        if context.state.status == "paused" {
            return "pause.fill"
        }

        switch context.state.phase {
        case "shortBreak", "longBreak":
            return "cup.and.saucer.fill"
        default:
            return "target"
        }
    }

    private func currentTimeBoxTitle(_ context: ActivityViewContext<PomodoroActivityAttributes>) -> String {
        let title = context.state.currentTimeBoxTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? phaseTitle(context) : title
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

@available(iOS 16.1, *)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PomodoroActivityAttributes>

    var body: some View {
        // LA는 실행 화면이므로 현재 타임박스(진행 중인 일)와 남은 시간만
        // 보여준다. 우선순위 목록 같은 계획 정보는 앱 안에서 본다.
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: phaseIcon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentTimeBoxTitle)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    if !context.state.currentTimeBoxTimeRange.isEmpty {
                        Text(context.state.currentTimeBoxTimeRange)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.58))
                            .lineLimit(1)
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                timerText(size: 28)
            }

            ProgressView(value: progressValue, total: Double(context.attributes.totalDuration))
                .tint(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .activityBackgroundTint(Color.black)
        .activitySystemActionForegroundColor(.white)
    }

    @ViewBuilder
    private func timerText(size: CGFloat) -> some View {
        if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
            Text(formatTime(seconds: pausedSeconds))
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        } else {
            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var progressValue: Double {
        if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
            return Double(pausedSeconds)
        }
        return max(0, context.state.endTime.timeIntervalSinceNow)
    }

    private var phaseTitle: String {
        if context.state.status == "paused" {
            return context.state.localizedPausedTitle
        }

        switch context.state.phase {
        case "shortBreak":
            return context.state.localizedShortBreakTitle
        case "longBreak":
            return context.state.localizedLongBreakTitle
        default:
            return context.state.localizedFocusTitle
        }
    }

    private var phaseIcon: String {
        if context.state.status == "paused" {
            return "pause.fill"
        }

        switch context.state.phase {
        case "shortBreak", "longBreak":
            return "cup.and.saucer.fill"
        default:
            return "target"
        }
    }

    private var currentTimeBoxTitle: String {
        let title = context.state.currentTimeBoxTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? phaseTitle : title
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
