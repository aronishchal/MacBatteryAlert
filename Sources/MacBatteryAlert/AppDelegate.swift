import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = BatteryAlertSettings()
    let launchAtLoginManager = LaunchAtLoginManager()
    lazy var alertPresenter = TopBannerPresenter()
    lazy var monitor = BatteryMonitor(settings: settings, presenter: alertPresenter)
    lazy var settingsWindowController = SettingsWindowController(
        settings: settings,
        monitor: monitor,
        launchAtLoginManager: launchAtLoginManager
    )

    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        NSApp.setActivationPolicy(.accessory)

        statusItemController = StatusItemController(
            monitor: monitor,
            openSettings: { [weak self] in
                self?.showSettingsWindow()
            }
        )
        monitor.start()
        showSettingsOnFirstLaunchIfNeeded()
    }

    func showSettingsWindow() {
        settingsWindowController.show()
    }

    private func showSettingsOnFirstLaunchIfNeeded() {
        guard settings.shouldShowOnboarding else { return }

        settings.markOnboardingShown()
        DispatchQueue.main.async { [weak self] in
            self?.showSettingsWindow()
        }
    }
}
