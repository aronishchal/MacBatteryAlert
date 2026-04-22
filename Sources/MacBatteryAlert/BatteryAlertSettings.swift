import Foundation
import Combine

final class BatteryAlertSettings: ObservableObject {
    @Published var lowBatteryThreshold: Int {
        didSet {
            lowBatteryThreshold = Self.clamp(lowBatteryThreshold)
            defaults.set(lowBatteryThreshold, forKey: Keys.lowBatteryThreshold)
        }
    }

    @Published var chargedThreshold: Int {
        didSet {
            chargedThreshold = Self.clamp(chargedThreshold)
            defaults.set(chargedThreshold, forKey: Keys.chargedThreshold)
        }
    }

    @Published var alertDuration: Double {
        didSet {
            alertDuration = min(max(alertDuration, 2), 12)
            defaults.set(alertDuration, forKey: Keys.alertDuration)
        }
    }

    var shouldShowOnboarding: Bool {
        !defaults.bool(forKey: Keys.hasShownOnboarding)
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedLow = defaults.object(forKey: Keys.lowBatteryThreshold) as? Int ?? 40
        let storedCharged = defaults.object(forKey: Keys.chargedThreshold) as? Int ?? 80
        let storedDuration = defaults.object(forKey: Keys.alertDuration) as? Double ?? 4.5

        lowBatteryThreshold = Self.clamp(storedLow)
        chargedThreshold = Self.clamp(storedCharged)
        alertDuration = min(max(storedDuration, 2), 12)
    }

    func markOnboardingShown() {
        defaults.set(true, forKey: Keys.hasShownOnboarding)
    }

    private static func clamp(_ value: Int) -> Int {
        min(max(value, 1), 100)
    }

    private enum Keys {
        static let lowBatteryThreshold = "lowBatteryThreshold"
        static let chargedThreshold = "chargedThreshold"
        static let alertDuration = "alertDuration"
        static let hasShownOnboarding = "hasShownOnboarding"
    }
}
