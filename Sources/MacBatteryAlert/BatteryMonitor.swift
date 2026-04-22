import Foundation
import Combine

@MainActor
final class BatteryMonitor: ObservableObject {
    @Published private(set) var snapshot = BatterySnapshot(percentage: 0, isCharging: false, powerSource: .unknown)
    @Published private(set) var lastAlertDescription = "No alerts yet"

    var menuBarSymbolName: String {
        if snapshot.isOnBattery {
            return snapshot.percentage <= settings.lowBatteryThreshold ? "battery.25" : "battery.75"
        }

        return snapshot.isCharging ? "battery.100.bolt" : "powerplug"
    }

    var menuBarTitle: String {
        "\(snapshot.percentage)%"
    }

    private let settings: BatteryAlertSettings
    private let presenter: TopBannerPresenter
    private var timer: Timer?
    private var lowBatteryAlertSent = false
    private var chargedAlertSent = false
    private var cancellables = Set<AnyCancellable>()

    init(settings: BatteryAlertSettings, presenter: TopBannerPresenter) {
        self.settings = settings
        self.presenter = presenter

        settings.$lowBatteryThreshold
            .sink { [weak self] _ in
                self?.rearmAlertsForCurrentState()
            }
            .store(in: &cancellables)

        settings.$chargedThreshold
            .sink { [weak self] _ in
                self?.rearmAlertsForCurrentState()
            }
            .store(in: &cancellables)
    }

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func refresh() {
        guard let updatedSnapshot = BatteryReader.currentSnapshot() else { return }
        let previousSnapshot = snapshot
        snapshot = updatedSnapshot
        evaluateAlerts(previous: previousSnapshot, current: updatedSnapshot)
    }

    func triggerTestLowBatteryAlert() {
        showAlert(
            title: "Battery low",
            subtitle: "Battery at \(min(snapshot.percentage, settings.lowBatteryThreshold))%. Plug in soon.",
            colorStyle: .warning
        )
    }

    func triggerTestChargedAlert() {
        showAlert(
            title: "Charge target reached",
            subtitle: "Battery at \(max(snapshot.percentage, settings.chargedThreshold))%. You can unplug now.",
            colorStyle: .success
        )
    }

    private func evaluateAlerts(previous: BatterySnapshot, current: BatterySnapshot) {
        if current.isOnBattery && current.percentage > settings.lowBatteryThreshold {
            lowBatteryAlertSent = false
        }

        if current.isPluggedIn && current.percentage < settings.chargedThreshold {
            chargedAlertSent = false
        }

        if previous.powerSource != current.powerSource {
            if current.isOnBattery {
                chargedAlertSent = false
            } else if current.isPluggedIn {
                lowBatteryAlertSent = false
            }
        }

        if current.isOnBattery && current.percentage <= settings.lowBatteryThreshold && !lowBatteryAlertSent {
            lowBatteryAlertSent = true
            showAlert(
                title: "Battery low",
                subtitle: "Battery at \(current.percentage)%. Plug in soon.",
                colorStyle: .warning
            )
        }

        if current.isPluggedIn && current.percentage >= settings.chargedThreshold && !chargedAlertSent {
            chargedAlertSent = true
            showAlert(
                title: "Charge target reached",
                subtitle: "Battery at \(current.percentage)%. You can unplug now.",
                colorStyle: .success
            )
        }
    }

    private func showAlert(title: String, subtitle: String, colorStyle: BannerStyle) {
        lastAlertDescription = "\(title) - \(subtitle)"
        presenter.show(
            title: title,
            subtitle: subtitle,
            style: colorStyle,
            duration: settings.alertDuration
        )
    }

    private func rearmAlertsForCurrentState() {
        lowBatteryAlertSent = snapshot.isOnBattery && snapshot.percentage <= settings.lowBatteryThreshold
        chargedAlertSent = snapshot.isPluggedIn && snapshot.percentage >= settings.chargedThreshold
    }
}
