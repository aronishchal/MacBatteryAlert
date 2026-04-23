import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    private let window: NSWindow

    init(settings: BatteryAlertSettings, monitor: BatteryMonitor, launchAtLoginManager: LaunchAtLoginManager) {
        let rootView = SettingsView(
            settings: settings,
            monitor: monitor,
            launchAtLoginManager: launchAtLoginManager
        )
        let hostingController = NSHostingController(rootView: rootView)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Battery Alert Settings"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = hostingController
        super.init()
        window.delegate = self
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}
