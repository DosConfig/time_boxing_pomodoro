import WidgetKit
import SwiftUI

@main
@available(iOS 16.1, *)
struct PomodoroWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomodoroWidgetLiveActivity()
    }
}
