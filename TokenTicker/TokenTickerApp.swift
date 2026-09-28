import SwiftUI
import AppKit
import CoreGraphics

@main
struct TokenTickerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Create window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 160, height: 160),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Window properties
        window.isOpaque = false
        window.backgroundColor = .clear
        // Reverted Sep 28: the desktop-icon layer only renders when nothing else covers
        // that screen region, so with any normal window over that spot the widget vanished
        // entirely — worse than the original "floats above" complaint. Back to .normal;
        // the orderFront-not-makeKey change below (which stops focus-stealing at launch)
        // stays, since that part was an unambiguous improvement.
        window.level = .normal
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.ignoresCycle]

        // Create a container view with rounded corners
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 22
        containerView.layer?.masksToBounds = true
        containerView.layer?.opacity = 0.97  // Was 0.85 — matches molty-meter's darker look

        // Visual effect view for background blur (like Apple widgets)
        let visualEffect = NSVisualEffectView(frame: containerView.bounds)
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow  // Was .menu — matches molty-meter's darker look
        visualEffect.appearance = NSAppearance(named: .darkAqua)  // Force dark appearance
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 22
        visualEffect.layer?.masksToBounds = true

        // Darkening overlay — was a white 0.2-alpha "lighten" layer; flipped to black
        // to match molty-meter's darker look (Liz's preferred style, applied to both).
        let lightenOverlay = NSView(frame: visualEffect.bounds)
        lightenOverlay.autoresizingMask = [.width, .height]
        lightenOverlay.wantsLayer = true
        lightenOverlay.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.35).cgColor
        visualEffect.addSubview(lightenOverlay)

        // SwiftUI content
        let hostingView = NSHostingView(rootView: ContentView())
        hostingView.frame = visualEffect.bounds
        hostingView.autoresizingMask = [.width, .height]

        // Make hosting view transparent
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = .clear

        visualEffect.addSubview(hostingView)
        containerView.addSubview(visualEffect)
        window.contentView = containerView

        // Restore position or center on first launch
        window.setFrameAutosaveName("TokenTickerWindow")
        if window.frame.origin == .zero {
            window.center()
        }
        // orderFront (not makeKeyAndOrderFront) — a desktop widget shouldn't steal
        // keyboard focus from whatever app you're actually using when it launches.
        window.orderFront(nil)
    }
}
