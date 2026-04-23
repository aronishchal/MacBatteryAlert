import Foundation
import Combine

@MainActor
final class BatteryMonitor: ObservableObject {
    @Published private(set) var snapshot = BatterySnapshot(percentage: 0, isCharging: false, powerSource: .unknown)
    @Published private(set) var lastAlertDescription = "No alerts yet"

    enum MenuBarState {
        case low
        case charging
        case charged
        case normal
    }

    var menuBarState: MenuBarState {
        if snapshot.isPluggedIn && snapshot.percentage >= settings.chargedThreshold {
            return .charged
        }

        if snapshot.isCharging {
            return .charging
        }

        if snapshot.isOnBattery && snapshot.percentage <= settings.lowBatteryThreshold {
            return .low
        }

        return .normal
    }

    private let settings: BatteryAlertSettings
    private let presenter: TopBannerPresenter
    private var timer: Timer?
    private var lowBatteryAlertSent = false
    private var chargedAlertSent = false
    private var hasStartedMonitoring = false
    private var cancellables = Set<AnyCancellable>()

    init(settings: BatteryAlertSettings, presenter: TopBannerPresenter) {
        self.settings = settings
        self.presenter = presenter

        settings.$lowBatteryThreshold
            .dropFirst()
            .sink { [weak self] _ in
                self?.handleLowThresholdChange()
            }
            .store(in: &cancellables)

        settings.$chargedThreshold
            .dropFirst()
            .sink { [weak self] _ in
                self?.handleChargedThresholdChange()
            }
            .store(in: &cancellables)
    }

    func start() {
        hasStartedMonitoring = true
        lowBatteryAlertSent = false
        chargedAlertSent = false
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

    private func handleLowThresholdChange() {
        guard hasStartedMonitoring else { return }
        lowBatteryAlertSent = false
        refresh()
    }

    private func handleChargedThresholdChange() {
        guard hasStartedMonitoring else { return }
        chargedAlertSent = false
        refresh()
    }
}
