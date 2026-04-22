import SwiftUI

@main
struct MacBatteryAlertApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(
                settings: appDelegate.settings,
                monitor: appDelegate.monitor,
                launchAtLoginManager: appDelegate.launchAtLoginManager
            )
            .frame(width: 400, height: 420)
        }
    }
}
