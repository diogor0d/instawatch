import SwiftUI

@main
struct InstaWatchApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                InboxView()
                    .tabItem {
                        Label("Inbox", systemImage: "envelope")
                    }
                
                PersonalShortcutsView()
                    .tabItem {
                        Label("Shortcuts", systemImage: "bolt")
                    }
                
                DebugView()
                    .tabItem {
                        Label("Debug", systemImage: "wrench")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
