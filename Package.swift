// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacBatteryAlert",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MacBatteryAlert", targets: ["MacBatteryAlert"])
    ],
    targets: [
        .executableTarget(
            name: "MacBatteryAlert",
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/MacBatteryAlert/Info.plist"
                ]),
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement")
            ]
        )
    ]
)
