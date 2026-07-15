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
                    Label(phaseTitle(context), systemImage: phaseIcon(context))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.sessionCount)/\(context.state.sessionGoal)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }

                DynamicIslandExpandedRegion(.center) {
                    timerText(context, size: 38)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: progressValue(context), total: Double(context.attributes.totalDuration))
                        .tint(.white)
                }
            } compactLeading: {
                Image(systemName: phaseIcon(context))
                    .foregroundStyle(.white)
            } compactTrailing: {
                timerText(context, size: 12)
            } minimal: {
                Image(systemName: "circle.hexagongrid.circle")
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
        } else {
            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
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
            return "Paused"
        }

        switch context.state.phase {
        case "shortBreak":
            return "Short break"
        case "longBreak":
            return "Long break"
        default:
            return "Focus"
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
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(phaseTitle, systemImage: phaseIcon)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(context.state.sessionCount)/\(context.state.sessionGoal)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.65))
            }

            HStack(alignment: .lastTextBaseline) {
                timerText

                Spacer()

                Text(context.state.status == "paused" ? "HOLD" : "LIVE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.48))
            }

            ProgressView(value: progressValue, total: Double(context.attributes.totalDuration))
                .tint(.white)
        }
        .padding(18)
        .activityBackgroundTint(Color.black)
        .activitySystemActionForegroundColor(.white)
    }

    @ViewBuilder
    private var timerText: some View {
        if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
            Text(formatTime(seconds: pausedSeconds))
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        } else {
            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
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
            return "Paused"
        }

        switch context.state.phase {
        case "shortBreak":
            return "Short break"
        case "longBreak":
            return "Long break"
        default:
            return "Focus"
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

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
