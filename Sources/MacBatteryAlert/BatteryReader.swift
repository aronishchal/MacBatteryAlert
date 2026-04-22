import Foundation
import IOKit.ps

enum BatteryReader {
    static func currentSnapshot() -> BatterySnapshot? {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef],
              let source = list.first,
              let description = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any]
        else {
            return nil
        }

        let currentCapacity = description[kIOPSCurrentCapacityKey as String] as? Int ?? 0
        let maxCapacity = description[kIOPSMaxCapacityKey as String] as? Int ?? 0
        let isCharging = description[kIOPSIsChargingKey as String] as? Bool ?? false
        let powerSourceState = description[kIOPSPowerSourceStateKey as String] as? String

        guard maxCapacity > 0 else { return nil }

        let percentage = Int((Double(currentCapacity) / Double(maxCapacity) * 100.0).rounded())
        let sourceKind: BatterySnapshot.PowerSource

        switch powerSourceState {
        case kIOPSBatteryPowerValue:
            sourceKind = .battery
        case kIOPSACPowerValue:
            sourceKind = .ac
        default:
            sourceKind = .unknown
        }

        return BatterySnapshot(
            percentage: min(max(percentage, 0), 100),
            isCharging: isCharging,
            powerSource: sourceKind
        )
    }
}
