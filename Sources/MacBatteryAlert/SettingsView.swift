import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: BatteryAlertSettings
    @ObservedObject var monitor: BatteryMonitor
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager

    @State private var lowBatteryInput = ""
    @State private var chargedInput = ""

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

            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Low battery threshold")
                        .font(.headline)
                    TextField("40", text: $lowBatteryInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 90)
                        .onSubmit {
                            applyLowBatteryInput()
                        }
                    Text("1 to 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Charged threshold")
                        .font(.headline)
                    TextField("80", text: $chargedInput)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 90)
                        .onSubmit {
                            applyChargedInput()
                        }
                    Text("1 to 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Banner duration: \(settings.alertDuration, specifier: "%.1f")s")
                    .font(.headline)
                Slider(value: $settings.alertDuration, in: 2...12, step: 0.5)
            }

            HStack(spacing: 12) {
                Button("Save Thresholds") {
                    applyLowBatteryInput()
                    applyChargedInput()
                }

                Button("Test Low Alert") {
                    monitor.triggerTestLowBatteryAlert()
                }

                Button("Test Charged Alert") {
                    monitor.triggerTestChargedAlert()
                }

            }

            Text("The app lives in your menu bar. Defaults are 40% for low battery and 80% for charged.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
        .onAppear {
            syncInputsFromSettings()
        }
        .onChange(of: settings.lowBatteryThreshold) { _ in
            lowBatteryInput = String(settings.lowBatteryThreshold)
        }
        .onChange(of: settings.chargedThreshold) { _ in
            chargedInput = String(settings.chargedThreshold)
        }
    }

    private func syncInputsFromSettings() {
        lowBatteryInput = String(settings.lowBatteryThreshold)
        chargedInput = String(settings.chargedThreshold)
    }

    private func applyLowBatteryInput() {
        settings.updateLowBatteryThreshold(Int(lowBatteryInput.trimmingCharacters(in: .whitespacesAndNewlines)) ?? settings.lowBatteryThreshold)
        lowBatteryInput = String(settings.lowBatteryThreshold)
    }

    private func applyChargedInput() {
        settings.updateChargedThreshold(Int(chargedInput.trimmingCharacters(in: .whitespacesAndNewlines)) ?? settings.chargedThreshold)
        chargedInput = String(settings.chargedThreshold)
    }
}
