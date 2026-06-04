import SwiftUI
import AppKit

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
        containerView.layer?.opacity = 0.85  // Add overall transparency

        // Visual effect view for background blur (like Apple widgets)
        let visualEffect = NSVisualEffectView(frame: containerView.bounds)
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .menu  // Lighter blur
        visualEffect.appearance = NSAppearance(named: .darkAqua)  // Force dark appearance
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 22
        visualEffect.layer?.masksToBounds = true

        // Lighten overlay to dial down darkness
        let lightenOverlay = NSView(frame: visualEffect.bounds)
        lightenOverlay.autoresizingMask = [.width, .height]
        lightenOverlay.wantsLayer = true
        lightenOverlay.layer?.backgroundColor = NSColor(white: 1.0, alpha: 0.2).cgColor
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
        window.makeKeyAndOrderFront(nil)
    }
}
