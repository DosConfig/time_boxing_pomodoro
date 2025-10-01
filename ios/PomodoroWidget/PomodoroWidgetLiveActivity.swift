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
                    Text(formatTime(seconds: context.state.remainingTime))
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .monospacedDigit()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: Double(context.state.remainingTime), total: Double(context.attributes.totalDuration))
                        .tint(.green)
                }

            } compactLeading: {
                // Compact leading (left side of Dynamic Island)
                Image(systemName: "timer")
                    .foregroundColor(.green)

            } compactTrailing: {
                // Compact trailing (right side of Dynamic Island)
                Text(formatTime(seconds: context.state.remainingTime))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.green)
                    .monospacedDigit()

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
                remainingTime: context.state.remainingTime,
                totalDuration: context.attributes.totalDuration
            )

            // Progress Bar
            ProgressView(
                value: Double(context.state.remainingTime),
                total: Double(context.attributes.totalDuration)
            )
            .tint(.green)
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
}

// MARK: - CRT Timer View

@available(iOS 16.1, *)
struct CRTTimerView: View {
    let remainingTime: Int
    let totalDuration: Int

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

            // Timer Text
            Text(formatTime(seconds: remainingTime))
                .font(.system(size: 48, weight: .regular, design: .monospaced))
                .foregroundColor(Color(red: 0.2, green: 1.0, blue: 0.53))
                .shadow(color: Color(red: 0.2, green: 1.0, blue: 0.53).opacity(0.8), radius: 10)
                .shadow(color: Color(red: 0.2, green: 1.0, blue: 0.53).opacity(0.5), radius: 20)
                .monospacedDigit()
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
