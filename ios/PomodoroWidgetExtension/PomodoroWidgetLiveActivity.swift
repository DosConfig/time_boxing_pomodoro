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
                        priorityText(context)
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

    @ViewBuilder
    private func priorityText(_ context: ActivityViewContext<PomodoroActivityAttributes>) -> some View {
        if let firstPriority = context.state.topPriorities.first {
            Text(firstPriority)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
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
        // 제목이 타이머와 폭을 다투지 않도록, 타이머는 우선순위 스트립과
        // 한 줄을 쓰고 현재 타임박스 제목은 전체 폭에서 최대 2줄로 그린다.
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                priorityStrip
                    .layoutPriority(1)

                Spacer(minLength: 8)

                timerText(size: 26)
            }

            currentBlockRow

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
    private var priorityStrip: some View {
        if let firstPriority = context.state.topPriorities.first {
            HStack(spacing: 8) {
                Text(context.state.localizedTopPriorityLabel)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.48))
                    .textCase(.uppercase)

                Text(firstPriority)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.86))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .layoutPriority(1)

                if context.state.topPriorities.count > 1 {
                    Text("+\(context.state.topPriorities.count - 1)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.52))
                }
            }
        }
    }

    private var currentBlockRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(currentTimeBoxTitle)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

            if !context.state.currentTimeBoxTimeRange.isEmpty {
                Text(context.state.currentTimeBoxTimeRange)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)
                    .monospacedDigit()
            }
        }
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
