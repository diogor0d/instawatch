import SwiftUI

struct ContentView: View {
    @StateObject private var apiService = InstagramAPIService.shared
    @State private var threads: [Thread] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if threads.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "message.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No conversations")
                            .font(.title2)
                        Button("Refresh") {
                            Task { await loadThreads() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(threads) { thread in
                        NavigationLink(destination: ThreadView(thread: thread)) {
                            ThreadRowView(thread: thread)
                        }
                    }
                }
            }
            .navigationTitle("Instagram")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task { await loadThreads() }
                    }
                }
            }
        }
        .task {
            // ADD THIS: Set up user ID when app starts
            await setupApp()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }
    
    // ADD THIS FUNCTION:
    private func setupApp() async {
    do {
        // Get real user ID from server
        let userInfo = try await apiService.getCurrentUser()
        InstagramAPIService.shared.setCurrentUserId(userInfo.userId)
    } catch {
        // Fallback to placeholder
        InstagramAPIService.shared.setCurrentUserId("placeholder_user_id")
    }
    await loadThreads()
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