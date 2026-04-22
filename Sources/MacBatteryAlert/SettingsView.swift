import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: BatteryAlertSettings
    @ObservedObject var monitor: BatteryMonitor
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Battery Alert")
                .font(.system(size: 24, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 6) {
                Text("Current battery")
                    .font(.headline)
                Text("\(monitor.snapshot.percentage)% • \(monitor.snapshot.statusText)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Toggle(
                "Launch at login",
                isOn: Binding(
                    get: { launchAtLoginManager.isEnabled },
                    set: { launchAtLoginManager.setEnabled($0) }
                )
            )
            .disabled(!launchAtLoginManager.isSupported)

            Text(launchAtLoginManager.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                Text("Low battery threshold: \(settings.lowBatteryThreshold)%")
                    .font(.headline)
                Slider(
                    value: Binding(
                        get: { Double(settings.lowBatteryThreshold) },
                        set: { settings.lowBatteryThreshold = Int($0.rounded()) }
                    ),
                    in: 5...95,
                    step: 1
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Charged threshold: \(settings.chargedThreshold)%")
                    .font(.headline)
                Slider(
                    value: Binding(
                        get: { Double(settings.chargedThreshold) },
                        set: { settings.chargedThreshold = Int($0.rounded()) }
                    ),
                    in: 10...100,
                    step: 1
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Banner duration: \(settings.alertDuration, specifier: "%.1f")s")
                    .font(.headline)
                Slider(value: $settings.alertDuration, in: 2...12, step: 0.5)
            }

            HStack(spacing: 12) {
                Button("Test Low Alert") {
                    monitor.triggerTestLowBatteryAlert()
                }

                Button("Test Charged Alert") {
                    monitor.triggerTestChargedAlert()
                }

                Button("Refresh Battery") {
                    monitor.refresh()
                    launchAtLoginManager.refresh()
                }
            }

            Text("The app lives in your menu bar. Defaults are 40% for low battery and 80% for charged.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
    }
}
