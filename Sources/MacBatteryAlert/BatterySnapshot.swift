import Foundation

struct BatterySnapshot: Equatable {
    enum PowerSource: Equatable {
        case battery
        case ac
        case unknown
    }

    let percentage: Int
    let isCharging: Bool
    let powerSource: PowerSource

    var statusText: String {
        switch (powerSource, isCharging) {
        case (.battery, _):
            return "On battery"
        case (.ac, true):
            return "Charging"
        case (.ac, false):
            return "Plugged in"
        case (.unknown, _):
            return "Power status unknown"
        }
    }

    var isOnBattery: Bool {
        powerSource == .battery
    }

    var isPluggedIn: Bool {
        powerSource == .ac
    }
}
