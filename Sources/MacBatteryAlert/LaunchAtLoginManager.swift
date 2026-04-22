import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var isSupported = false
    @Published private(set) var statusMessage = "Launch at login is available in the packaged app."

    init() {
        refresh()
    }

    func refresh() {
        let bundleURL = Bundle.main.bundleURL
        isSupported = bundleURL.pathExtension == "app"

        guard isSupported else {
            isEnabled = false
            statusMessage = "Build and run the .app bundle to enable launch at login."
            return
        }

        let service = SMAppService.mainApp
        switch service.status {
        case .enabled:
            isEnabled = true
            statusMessage = "Mac Battery Alert will open automatically when you log in."
        case .requiresApproval:
            isEnabled = false
            statusMessage = "Enable Mac Battery Alert in Login Items if macOS asks for approval."
        case .notRegistered, .notFound:
            isEnabled = false
            statusMessage = "Launch at login is currently off."
        @unknown default:
            isEnabled = false
            statusMessage = "Launch at login status is unavailable right now."
        }
    }

    func setEnabled(_ enabled: Bool) {
        guard isSupported else {
            refresh()
            return
        }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            refresh()
        } catch {
            refresh()
            statusMessage = "macOS could not update login items: \(error.localizedDescription)"
        }
    }
}
