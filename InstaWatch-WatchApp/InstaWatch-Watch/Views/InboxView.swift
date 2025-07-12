import SwiftUI

struct InboxView: View {
    @StateObject private var networkManager = NetworkManager.shared
    @State private var threads: [Thread] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading && threads.isEmpty {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if threads.isEmpty {
                    ContentUnavailableView(
                        "No Messages",
                        systemImage: "message.circle",
                        description: Text("Pull to refresh")
                    )
                } else {
                    List(threads) { thread in
                        NavigationLink(destination: ThreadView(thread: thread)) {
                            ThreadRowView(thread: thread)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .refreshable {
                        await loadInbox()
                    }
                }
            }
            .navigationTitle("Instagram")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await loadInbox()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .task {
            await loadInbox()
        }
    }
    
    private func loadInbox() async {
        isLoading = true
        errorMessage = nil
        
        do {
            threads = try await networkManager.fetchInbox()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    InboxView()
}
