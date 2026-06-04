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
    private var appearanceObservation: NSKeyValueObservation?

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

        // Create a container view with rounded corners and solid translucent background
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 22
        containerView.layer?.masksToBounds = true

        // Set initial background based on appearance
        updateBackgroundForAppearance(containerView: containerView)

        // Observe appearance changes
        appearanceObservation = NSApp.observe(\.effectiveAppearance) { [weak self, weak containerView] _, _ in
            Task { @MainActor in
                if let containerView = containerView {
                    self?.updateBackgroundForAppearance(containerView: containerView)
                }
            }
        }

        // SwiftUI content
        let hostingView = NSHostingView(rootView: ContentView())
        hostingView.frame = containerView.bounds
        hostingView.autoresizingMask = [.width, .height]

        // Make hosting view transparent
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = .clear

        containerView.addSubview(hostingView)
        window.contentView = containerView

        // Restore position or center on first launch
        window.setFrameAutosaveName("TokenTickerWindow")
        if window.frame.origin == .zero {
            window.center()
        }
        window.makeKeyAndOrderFront(nil)
    }

    private func updateBackgroundForAppearance(containerView: NSView) {
        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

        if isDark {
            // Dark mode: pure black (#000) semi-transparent background
            containerView.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.3).cgColor
        } else {
            // Light mode: dark background like Weather widget (white text on dark)
            containerView.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.3).cgColor
        }
    }
}
