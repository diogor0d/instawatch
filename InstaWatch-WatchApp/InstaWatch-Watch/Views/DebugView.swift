import SwiftUI

struct DebugView: View {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var settingsManager = SettingsManager()
    @State private var debugOutput: String = "Debug output will appear here..."
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Quick API tests
                    Section {
                        Button("Test Unread Count") {
                            testUnreadCount()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Test Inbox") {
                            testInbox()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Clear Debug") {
                            debugOutput = ""
                        }
                        .buttonStyle(.borderedProminent)
                    } header: {
                        Text("API Tests")
                            .font(.headline)
                    }
                    
                    // Debug output
                    Section {
                        Text(debugOutput)
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                    } header: {
                        Text("Debug Output")
                            .font(.headline)
                    }
                    
                    // Current settings
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Backend: \(settingsManager.backendURL)")
                            Text("Auto-refresh: \(settingsManager.autoRefresh ? "ON" : "OFF")")
                            Text("Refresh interval: \(settingsManager.refreshInterval)s")
                            Text("Message limit: \(settingsManager.messageLimit)")
                        }
                        .font(.caption)
                    } header: {
                        Text("Current Settings")
                            .font(.headline)
                    }
                }
                .padding()
            }
            .navigationTitle("Debug")
        }
    }
    
    private func testUnreadCount() {
        debugOutput += "\\n[$(getCurrentTime())] Testing unread count..."
        
        networkManager.getUnreadCount { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let count):
                    debugOutput += "\\n✅ Unread count: \\(count.unreadCount)"
                case .failure(let error):
                    debugOutput += "\\n❌ Error: \\(error.localizedDescription)"
                }
            }
        }
    }
    
    private func testInbox() {
        debugOutput += "\\n[$(getCurrentTime())] Testing inbox..."
        
        networkManager.getInbox { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let threads):
                    debugOutput += "\\n✅ Found \\(threads.count) threads"
                    for thread in threads.prefix(3) {
                        debugOutput += "\\n  - \\(thread.title): \\(thread.lastMessage)"
                    }
                case .failure(let error):
                    debugOutput += "\\n❌ Error: \\(error.localizedDescription)"
                }
            }
        }
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
}

#Preview {
    DebugView()
}
