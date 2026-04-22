import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = BatteryAlertSettings()
    let launchAtLoginManager = LaunchAtLoginManager()
    lazy var alertPresenter = TopBannerPresenter()
    lazy var monitor = BatteryMonitor(settings: settings, presenter: alertPresenter)

    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        NSApp.setActivationPolicy(.accessory)

        statusItemController = StatusItemController(monitor: monitor)
        monitor.start()
        showSettingsOnFirstLaunchIfNeeded()
    }

    private func showSettingsOnFirstLaunchIfNeeded() {
        guard settings.shouldShowOnboarding else { return }

        settings.markOnboardingShown()

        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
    }
}
