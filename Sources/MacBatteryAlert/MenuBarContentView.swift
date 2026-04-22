import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var monitor: BatteryMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Battery Alert")
                    .font(.system(size: 15, weight: .bold))

                Text("\(monitor.snapshot.percentage)%")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))

                Text(monitor.snapshot.statusText)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Text(monitor.lastAlertDescription)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            Button("Refresh Now") {
                monitor.refresh()
            }

            Button("Settings…") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }

            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 280)
    }
}
