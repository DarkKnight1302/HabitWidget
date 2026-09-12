import SwiftUI
import AppKit

@main
struct HabitWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = HabitStore()

    var body: some Scene {
        Window("Habit", id: "habit") {
            ContentView()
                .environmentObject(store)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 340, height: 460)

        MenuBarExtra("Habit", systemImage: "checkmark.circle.fill") {
            MenuBarContent()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.menu)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { configure(view.window) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { configure(nsView.window) }
    }

    private func configure(_ window: NSWindow?) {
        guard let window else { return }
        window.level = .normal
        window.collectionBehavior = [.stationary]
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }
}

struct MenuBarContent: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Show Widget") {
            openWindow(id: "habit")
            NSApp.activate(ignoringOtherApps: true)
        }

        if !store.habits.isEmpty {
            Divider()
            ForEach(store.habits) { habit in
                Button {
                    store.selectedHabitID = habit.id
                } label: {
                    if store.selectedHabit?.id == habit.id {
                        Label(habit.name, systemImage: "checkmark")
                    } else {
                        Text(habit.name)
                    }
                }
            }
        }

        Divider()
        Button("Quit") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
