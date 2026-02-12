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
        window.level = .floating
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        // Visual effect background
        let visualEffect = NSVisualEffectView(frame: window.contentView!.bounds)
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .sidebar
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 22
        visualEffect.layer?.masksToBounds = true

        // SwiftUI content
        let hostingView = NSHostingView(rootView: ContentView())
        hostingView.frame = visualEffect.bounds
        hostingView.autoresizingMask = [.width, .height]

        // Make hosting view transparent
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = .clear
        hostingView.layer?.cornerRadius = 22
        hostingView.layer?.masksToBounds = true

        visualEffect.addSubview(hostingView)
        window.contentView = visualEffect

        // Set window corner radius
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 22
        window.contentView?.layer?.masksToBounds = true

        // Position and show
        window.center()
        
        // Round window corners
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 22
        window.contentView?.layer?.masksToBounds = true
        
        window.makeKeyAndOrderFront(nil)
    }
}
