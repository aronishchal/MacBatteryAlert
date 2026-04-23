import AppKit
import SwiftUI

enum BannerStyle {
    case warning
    case success

    var gradient: LinearGradient {
        switch self {
        case .warning:
            return LinearGradient(
                colors: [Color(red: 0.93, green: 0.41, blue: 0.15), Color(red: 0.98, green: 0.68, blue: 0.23)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .success:
            return LinearGradient(
                colors: [Color(red: 0.10, green: 0.58, blue: 0.34), Color(red: 0.25, green: 0.78, blue: 0.55)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    var symbol: String {
        switch self {
        case .warning: return "battery.25"
        case .success: return "battery.100.bolt"
        }
    }
}

@MainActor
final class TopBannerPresenter {
    private var window: NSPanel?
    private var hideTask: Task<Void, Never>?

    func show(title: String, subtitle: String, style: BannerStyle, duration: Double) {
        hideTask?.cancel()

        let content = BannerView(title: title, subtitle: subtitle, style: style)
        let hostingView = NSHostingView(rootView: content)
        hostingView.frame = NSRect(x: 0, y: 0, width: 420, height: 92)

        let panel = panelForDisplay()
        panel.contentView = hostingView
        panel.setContentSize(hostingView.frame.size)

        guard let screen = NSScreen.screens.first(where: { $0.frame.intersects(NSEvent.mouseLocationRect) }) ?? NSScreen.main else {
            return
        }

        let width: CGFloat = 420
        let height: CGFloat = 92
        let visibleFrame = screen.visibleFrame
        let originX = visibleFrame.midX - width / 2
        let menuBarHeight = max(0, screen.frame.maxY - visibleFrame.maxY)
        let topInset: CGFloat = 124
        let animationLift: CGFloat = 52
        let shownY = screen.frame.maxY - menuBarHeight - height - topInset
        let hiddenY = shownY + height + animationLift

        panel.setFrame(NSRect(x: originX, y: hiddenY, width: width, height: height), display: true)
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrameOrigin(NSPoint(x: originX, y: shownY))
            panel.animator().alphaValue = 1
        }

        hideTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            await hide(panel: panel, x: originX, y: hiddenY)
        }
    }

    private func panelForDisplay() -> NSPanel {
        if let window {
            return window
        }

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.ignoresMouseEvents = true
        panel.alphaValue = 1
        window = panel
        return panel
    }

    private func hide(panel: NSPanel, x: CGFloat, y: CGFloat) async {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().setFrameOrigin(NSPoint(x: x, y: y))
            panel.animator().alphaValue = 0.98
        } completionHandler: {
            panel.orderOut(nil)
        }
    }
}

private extension NSEvent {
    static var mouseLocationRect: NSRect {
        let point = mouseLocation
        return NSRect(x: point.x, y: point.y, width: 1, height: 1)
    }
}

private struct BannerView: View {
    let title: String
    let subtitle: String
    let style: BannerStyle

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: style.symbol)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(style.gradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 20, x: 0, y: 14)
        .padding(1)
    }
}
