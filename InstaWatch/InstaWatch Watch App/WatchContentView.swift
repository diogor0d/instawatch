import SwiftUI

struct WatchContentView: View {
    @StateObject private var apiService = SharedAPIService.shared
    @State private var threads: [SharedThread] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                        .font(.caption)
                } else if threads.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "message.circle")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("No messages")
                            .font(.caption)
                        Button("Refresh") {
                            Task { await loadThreads() }
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.caption)
                    }
                } else {
                    List(threads) { thread in
                        NavigationLink(destination: WatchThreadView(thread: thread)) {
                            WatchThreadRowView(thread: thread)
                        }
                    }
                }
            }
            .navigationTitle("Instagram")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadThreads()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }
    
    private func loadThreads() async {
        isLoading = true
        do {
            threads = try await apiService.getInbox()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
}

struct WatchThreadRowView: View {
    let thread: SharedThread
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(thread.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                if thread.unreadCount > 0 {
                    Text("\(thread.unreadCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
            
            Text(thread.lastMessage)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack {
                Spacer()
                Text(thread.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 1)
    }
}