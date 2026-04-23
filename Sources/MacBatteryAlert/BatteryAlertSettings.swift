import Foundation
import Combine

final class BatteryAlertSettings: ObservableObject {
    @Published private(set) var lowBatteryThreshold: Int
    @Published private(set) var chargedThreshold: Int
    @Published var alertDuration: Double {
        didSet {
            let clamped = min(max(alertDuration, 2), 12)
            if alertDuration != clamped {
                alertDuration = clamped
                return
            }
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

    func updateLowBatteryThreshold(_ value: Int) {
        let clamped = Self.clamp(value)
        guard lowBatteryThreshold != clamped else { return }
        lowBatteryThreshold = clamped
        defaults.set(clamped, forKey: Keys.lowBatteryThreshold)
    }

    func updateChargedThreshold(_ value: Int) {
        let clamped = Self.clamp(value)
        guard chargedThreshold != clamped else { return }
        chargedThreshold = clamped
        defaults.set(clamped, forKey: Keys.chargedThreshold)
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
