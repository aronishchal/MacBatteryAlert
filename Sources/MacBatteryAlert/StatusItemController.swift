import AppKit
import Combine

@MainActor
final class StatusItemController: NSObject {
    private let monitor: BatteryMonitor
    private let openSettingsAction: () -> Void
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()

    private let batteryItem = NSMenuItem(title: "Battery: --", action: nil, keyEquivalent: "")
    private let statusItemDescription = NSMenuItem(title: "Status: --", action: nil, keyEquivalent: "")
    private let lastAlertItem = NSMenuItem(title: "Last alert: No alerts yet", action: nil, keyEquivalent: "")

    private var cancellables = Set<AnyCancellable>()

    init(monitor: BatteryMonitor, openSettings: @escaping () -> Void) {
        self.monitor = monitor
        self.openSettingsAction = openSettings
        super.init()
        configureMenu()
        bindMonitor()
        updateButton()
        updateMenuItems()
    }

    private func configureMenu() {
        batteryItem.isEnabled = false
        statusItemDescription.isEnabled = false
        lastAlertItem.isEnabled = false

        menu.addItem(batteryItem)
        menu.addItem(statusItemDescription)
        menu.addItem(lastAlertItem)
        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let lowTestItem = NSMenuItem(title: "Test Low Battery Alert", action: #selector(testLowAlert), keyEquivalent: "")
        lowTestItem.target = self
        menu.addItem(lowTestItem)

        let chargedTestItem = NSMenuItem(title: "Test Charged Alert", action: #selector(testChargedAlert), keyEquivalent: "")
        chargedTestItem.target = self
        menu.addItem(chargedTestItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func bindMonitor() {
        monitor.$snapshot
            .sink { [weak self] _ in
                self?.updateButton()
                self?.updateMenuItems()
            }
            .store(in: &cancellables)

        monitor.$lastAlertDescription
            .sink { [weak self] _ in
                self?.updateMenuItems()
            }
            .store(in: &cancellables)
    }

    private func updateButton() {
        guard let button = statusItem.button else { return }
        button.title = ""
        button.attributedTitle = NSAttributedString(string: "")
        button.toolTip = "Battery Alert: \(monitor.snapshot.percentage)% - \(monitor.snapshot.statusText)"
        let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        button.image = NSImage(systemSymbolName: "bell.badge", accessibilityDescription: "Notifier")?.withSymbolConfiguration(config)
        button.imageScaling = .scaleProportionallyDown

        if let cell = button.cell as? NSButtonCell {
            cell.highlightsBy = []
        }
    }

    private func updateMenuItems() {
        batteryItem.title = "Battery: \(monitor.snapshot.percentage)%"
        statusItemDescription.title = "Status: \(monitor.snapshot.statusText)"
        lastAlertItem.title = "Last alert: \(monitor.lastAlertDescription)"
    }

    @objc private func openSettings() {
        openSettingsAction()
    }

    @objc private func testLowAlert() {
        monitor.triggerTestLowBatteryAlert()
    }

    @objc private func testChargedAlert() {
        monitor.triggerTestChargedAlert()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
