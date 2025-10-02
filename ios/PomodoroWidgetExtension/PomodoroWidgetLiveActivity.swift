import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct PomodoroWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.green)
                        Text("Pomodoro")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.sessionCount)/5")
                        .font(.caption)
                        .foregroundColor(.white)
                }

                DynamicIslandExpandedRegion(.center) {
                    if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
                        // 일시정지 상태: 정적 시간 표시
                        Text(formatTime(seconds: pausedSeconds))
                            .font(.custom("DOSIyagi", size: 40))
                            .foregroundColor(.yellow)
                            .monospacedDigit()
                    } else {
                        // 실행 중: 자동 카운트다운
                        Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                            .font(.custom("DOSIyagi", size: 40))
                            .foregroundColor(.green)
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    let progressVal = context.state.status == "paused" && context.state.pausedRemainingSeconds != nil
                        ? Double(context.state.pausedRemainingSeconds!)
                        : max(0, context.state.endTime.timeIntervalSinceNow)

                    ProgressView(value: progressVal, total: Double(context.attributes.totalDuration))
                        .tint(context.state.status == "paused" ? .yellow : .green)
                }

            } compactLeading: {
                // Compact leading (left side of Dynamic Island)
                Image(systemName: "timer")
                    .foregroundColor(.green)

            } compactTrailing: {
                // Compact trailing (right side of Dynamic Island)
                if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
                    Text(formatTime(seconds: pausedSeconds))
                        .font(.custom("DOSIyagi", size: 12))
                        .foregroundColor(.yellow)
                        .monospacedDigit()
                } else {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.custom("DOSIyagi", size: 12))
                        .foregroundColor(.green)
                        .monospacedDigit()
                }

            } minimal: {
                // Minimal (when multiple activities)
                Image(systemName: "timer")
                    .foregroundColor(.green)
            }
        }
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Lock Screen UI

@available(iOS 16.1, *)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PomodoroActivityAttributes>

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(statusText)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(context.state.sessionCount)/5")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            // CRT Style Timer Display
            CRTTimerView(
                context: context
            )

            // Progress Bar
            ProgressView(
                value: progressValue,
                total: Double(context.attributes.totalDuration)
            )
            .tint(context.state.status == "paused" ? .yellow : .green)
            .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .activityBackgroundTint(Color.black.opacity(0.8))
        .activitySystemActionForegroundColor(Color.green)
    }

    private var statusText: String {
        switch context.state.status {
        case "running":
            return "Focus Time! 🎯"
        case "paused":
            return "Paused ⏸"
        case "break":
            return "Break Time! ☕️"
        default:
            return "Pomodoro"
        }
    }

    private var progressValue: Double {
        if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
            return Double(pausedSeconds)
        } else {
            let remaining = context.state.endTime.timeIntervalSinceNow
            return max(0, remaining)
        }
    }
}

// MARK: - CRT Timer View

@available(iOS 16.1, *)
struct CRTTimerView: View {
    let context: ActivityViewContext<PomodoroActivityAttributes>

    var body: some View {
        ZStack {
            // CRT Background
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.04, green: 0.23, blue: 0.16),
                            Color(red: 0.02, green: 0.15, blue: 0.1),
                            Color.black
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .overlay(
                    // Scanlines effect
                    ScanlineOverlay()
                )
                .cornerRadius(12)

            // Timer Text with auto-countdown
            if context.state.status == "paused", let pausedSeconds = context.state.pausedRemainingSeconds {
                // 일시정지: 정적 시간 표시
                Text(formatTime(seconds: pausedSeconds))
                    .font(.custom("DOSIyagi", size: 48))
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.8), radius: 10)
                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.5), radius: 20)
                    .monospacedDigit()
            } else {
                // 실행 중: 자동 카운트다운
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .font(.custom("DOSIyagi", size: 48))
                    .foregroundColor(Color(red: 0.2, green: 1.0, blue: 0.53))
                    .shadow(color: Color(red: 0.2, green: 1.0, blue: 0.53).opacity(0.8), radius: 10)
                    .shadow(color: Color(red: 0.2, green: 1.0, blue: 0.53).opacity(0.5), radius: 20)
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 100)
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Scanline Overlay

struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                var y: CGFloat = 0
                while y < height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    y += 3
                }
            }
            .stroke(Color.black.opacity(0.3), lineWidth: 1)
        }
    }
}
