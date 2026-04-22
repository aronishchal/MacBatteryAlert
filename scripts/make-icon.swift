import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let buildDir = root.appendingPathComponent(".build-app")
let iconsetDir = buildDir.appendingPathComponent("AppIcon.iconset")
let icnsURL = buildDir.appendingPathComponent("AppIcon.icns")

try? FileManager.default.removeItem(at: iconsetDir)
try? FileManager.default.removeItem(at: icnsURL)
try FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

let specs: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

func color(_ r: Double, _ g: Double, _ b: Double) -> NSColor {
    NSColor(calibratedRed: r, green: g, blue: b, alpha: 1)
}

func makeImage(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let radius = CGFloat(size) * 0.23
    let inset = CGFloat(size) * 0.08
    let innerRect = rect.insetBy(dx: inset, dy: inset)
    let bezelRect = innerRect.insetBy(dx: CGFloat(size) * 0.12, dy: CGFloat(size) * 0.2)

    let gradient = NSGradient(colors: [
        color(0.96, 0.62, 0.23),
        color(0.94, 0.34, 0.18)
    ])!
    let bgPath = NSBezierPath(roundedRect: rect.insetBy(dx: CGFloat(size) * 0.03, dy: CGFloat(size) * 0.03), xRadius: radius, yRadius: radius)
    gradient.draw(in: bgPath, angle: -35)

    NSColor.white.withAlphaComponent(0.14).setStroke()
    bgPath.lineWidth = max(2, CGFloat(size) * 0.02)
    bgPath.stroke()

    let bezelPath = NSBezierPath(roundedRect: bezelRect, xRadius: CGFloat(size) * 0.12, yRadius: CGFloat(size) * 0.12)
    color(0.09, 0.17, 0.18).setFill()
    bezelPath.fill()

    let batteryBody = bezelRect.insetBy(dx: CGFloat(size) * 0.06, dy: CGFloat(size) * 0.07)
    let terminalWidth = batteryBody.width * 0.08
    let terminalHeight = batteryBody.height * 0.22
    let bodyRect = NSRect(x: batteryBody.minX, y: batteryBody.minY, width: batteryBody.width - terminalWidth * 1.5, height: batteryBody.height)
    let terminalRect = NSRect(x: bodyRect.maxX + terminalWidth * 0.4, y: bodyRect.midY - terminalHeight / 2, width: terminalWidth, height: terminalHeight)

    let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: CGFloat(size) * 0.05, yRadius: CGFloat(size) * 0.05)
    NSColor.white.withAlphaComponent(0.96).setStroke()
    bodyPath.lineWidth = max(3, CGFloat(size) * 0.045)
    bodyPath.stroke()

    let terminalPath = NSBezierPath(roundedRect: terminalRect, xRadius: terminalWidth / 2, yRadius: terminalWidth / 2)
    NSColor.white.withAlphaComponent(0.96).setFill()
    terminalPath.fill()

    let fillRect = bodyRect.insetBy(dx: CGFloat(size) * 0.045, dy: CGFloat(size) * 0.045)
    let leftFill = NSRect(x: fillRect.minX, y: fillRect.minY, width: fillRect.width * 0.38, height: fillRect.height)
    let rightFill = NSRect(x: fillRect.minX + fillRect.width * 0.46, y: fillRect.minY, width: fillRect.width * 0.18, height: fillRect.height)
    let gapFill = NSRect(x: fillRect.minX + fillRect.width * 0.66, y: fillRect.minY, width: fillRect.width * 0.12, height: fillRect.height)

    color(0.28, 0.86, 0.56).setFill()
    NSBezierPath(roundedRect: leftFill, xRadius: CGFloat(size) * 0.025, yRadius: CGFloat(size) * 0.025).fill()
    color(0.98, 0.79, 0.21).setFill()
    NSBezierPath(roundedRect: rightFill, xRadius: CGFloat(size) * 0.025, yRadius: CGFloat(size) * 0.025).fill()
    color(0.95, 0.44, 0.24).setFill()
    NSBezierPath(roundedRect: gapFill, xRadius: CGFloat(size) * 0.025, yRadius: CGFloat(size) * 0.025).fill()

    image.unlockFocus()
    return image
}

for (size, name) in specs {
    let image = makeImage(size: size)
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "Icon", code: 1)
    }
    try png.write(to: iconsetDir.appendingPathComponent(name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetDir.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()
if process.terminationStatus != 0 {
    throw NSError(domain: "Icon", code: Int(process.terminationStatus))
}
