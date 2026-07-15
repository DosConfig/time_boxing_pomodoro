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
                    Label(currentTimeBoxTitle(context), systemImage: phaseIcon(context))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.sessionCount)/\(context.state.sessionGoal)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }

                DynamicIslandExpandedRegion(.center) {
                    timerText(context, size: 34)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 7) {
                        if let firstPriority = context.state.topPriorities.first {
                            Text(firstPriority)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.72))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }

                        ProgressView(value: progressValue(context), total: Double(context.attributes.totalDuration))
                            .tint(.white)
                    }
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
        ViewThatFits(in: .vertical) {
            detailedContent
            compactContent
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .activityBackgroundTint(Color.black)
        .activitySystemActionForegroundColor(.white)
    }

    private var detailedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            priorityStrip
            statusRow
            currentBlockRow

            HStack(alignment: .lastTextBaseline) {
                timerText(size: 36)
                    .layoutPriority(1)

                Spacer(minLength: 12)

                Text(context.state.status == "paused" ? "HOLD" : "LIVE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.48))
            }

            ProgressView(value: progressValue, total: Double(context.attributes.totalDuration))
                .tint(.white)
        }
    }

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            priorityStrip

            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    statusRow
                    currentBlockRow
                }
                .layoutPriority(1)

                timerText(size: 30)
                    .layoutPriority(2)
            }

            ProgressView(value: progressValue, total: Double(context.attributes.totalDuration))
                .tint(.white)
        }
    }

    @ViewBuilder
    private var priorityStrip: some View {
        if let firstPriority = context.state.topPriorities.first {
            HStack(spacing: 8) {
                Text("Top priority")
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

    private var statusRow: some View {
        HStack(spacing: 8) {
            Label(phaseTitle, systemImage: phaseIcon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .layoutPriority(1)

            Spacer(minLength: 8)

            Text("\(context.state.sessionCount)/\(context.state.sessionGoal)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.65))
                .monospacedDigit()
        }
    }

    private var currentBlockRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(currentTimeBoxTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .layoutPriority(1)

            if !context.state.currentTimeBoxTimeRange.isEmpty {
                Text(context.state.currentTimeBoxTimeRange)
                    .font(.caption.weight(.semibold))
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
                .minimumScaleFactor(0.76)
        } else {
            Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.76)
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
