import AppKit

enum BatteryStatusIconFactory {
    static func makeImage(for state: BatteryMonitor.MenuBarState) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        let stroke = NSColor.labelColor
        stroke.setStroke()
        stroke.setFill()

        let bodyRect = NSRect(x: 2.2, y: 4.6, width: 11.8, height: 8.8)
        let terminalRect = NSRect(x: 14.6, y: 7.2, width: 1.8, height: 3.6)

        let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: 2.6, yRadius: 2.6)
        bodyPath.lineWidth = 1.6
        bodyPath.stroke()
        NSBezierPath(roundedRect: terminalRect, xRadius: 0.8, yRadius: 0.8).fill()

        switch state {
        case .normal:
            fillSegment(in: bodyRect, fraction: 0.58)
        case .low:
            fillSegment(in: bodyRect, fraction: 0.22)
            let mark = NSBezierPath()
            mark.move(to: NSPoint(x: 9.6, y: 3.3))
            mark.line(to: NSPoint(x: 10.8, y: 1.8))
            mark.lineWidth = 1.6
            mark.lineCapStyle = .round
            mark.stroke()
            let dot = NSBezierPath(ovalIn: NSRect(x: 9.2, y: 0.8, width: 1.9, height: 1.9))
            dot.fill()
        case .charging:
            let bolt = NSBezierPath()
            bolt.move(to: NSPoint(x: 8.0, y: 12.8))
            bolt.line(to: NSPoint(x: 6.5, y: 9.5))
            bolt.line(to: NSPoint(x: 8.6, y: 9.5))
            bolt.line(to: NSPoint(x: 7.4, y: 5.3))
            bolt.line(to: NSPoint(x: 10.9, y: 9.0))
            bolt.line(to: NSPoint(x: 8.7, y: 9.0))
            bolt.close()
            bolt.fill()
        case .charged:
            fillSegment(in: bodyRect, fraction: 0.82)
            let check = NSBezierPath()
            check.move(to: NSPoint(x: 5.2, y: 8.3))
            check.line(to: NSPoint(x: 7.0, y: 6.4))
            check.line(to: NSPoint(x: 10.9, y: 10.7))
            check.lineWidth = 1.7
            check.lineCapStyle = .round
            check.lineJoinStyle = .round
            check.stroke()
        }

        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private static func fillSegment(in bodyRect: NSRect, fraction: CGFloat) {
        let insetRect = bodyRect.insetBy(dx: 1.8, dy: 1.8)
        let width = max(2.2, insetRect.width * fraction)
        let fillRect = NSRect(x: insetRect.minX, y: insetRect.minY, width: min(width, insetRect.width), height: insetRect.height)
        let path = NSBezierPath(roundedRect: fillRect, xRadius: 1.4, yRadius: 1.4)
        path.fill()
    }
}
