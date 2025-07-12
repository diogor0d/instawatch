import SwiftUI

struct PersonalShortcutsView: View {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Quick status check
                StatusCardView()
                
                // Rapid fire replies
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ShortcutButton(title: "👍", subtitle: "Thumbs up") {
                            sendToLastThread("thumbs_up")
                        }
                        
                        ShortcutButton(title: "❤️", subtitle: "Heart") {
                            sendToLastThread("heart")
                        }
                        
                        ShortcutButton(title: "✅", subtitle: "OK") {
                            sendToLastThread("ok")
                        }
                        
                        ShortcutButton(title: "🚫", subtitle: "Busy") {
                            sendToLastThread("busy")
                        }
                    }
                } header: {
                    Text("Quick Replies to Last Thread")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Shortcuts")
        }
    }
    
    private func sendToLastThread(_ replyType: String) {
        // For personal use - send to the most recent thread
        // This is a shortcut that wouldn't be in a public app
        networkManager.getInbox { result in
            if case .success(let threads) = result,
               let lastThread = threads.first {
                networkManager.sendQuickReply(to: lastThread.id, replyType: replyType) { _ in
                    // Add haptic feedback if enabled
                    if settingsManager.hapticFeedback {
                        // WKInterfaceDevice.current().play(.click)
                    }
                }
            }
        }
    }
}

struct ShortcutButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.title2)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct StatusCardView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var unreadCount: Int = 0
    @State private var lastUpdate: Date = Date()
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("📱")
                    .font(.title2)
                Text("\\(unreadCount) unread")
                    .font(.headline)
                Spacer()
                Button("↻") {
                    refresh()
                }
                .font(.caption)
            }
            
            Text("Last update: \\(lastUpdate, style: .time)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            refresh()
        }
    }
    
    private func refresh() {
        networkManager.getUnreadCount { result in
            DispatchQueue.main.async {
                if case .success(let count) = result {
                    unreadCount = count.unreadCount
                    lastUpdate = Date()
                }
            }
        }
    }
}

#Preview {
    PersonalShortcutsView()
}
