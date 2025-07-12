import SwiftUI

struct ThreadView: View {
    let thread: Thread
    @StateObject private var networkManager = NetworkManager.shared
    @State private var messages: [Message] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingQuickReplies = false
    @State private var newMessageText = ""
    @State private var showingTextInput = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                Group {
                    if isLoading && messages.isEmpty {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if messages.isEmpty {
                        ContentUnavailableView(
                            "No Messages",
                            systemImage: "message.circle"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(messages.reversed()) { message in
                                    MessageBubbleView(message: message)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .defaultScrollAnchor(.bottom)
                    }
                }
                
                // Quick Action Buttons
                HStack(spacing: 8) {
                    Button {
                        showingQuickReplies = true
                    } label: {
                        Image(systemName: "bubble.left.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    
                    Button {
                        showingTextInput = true
                    } label: {
                        Image(systemName: "keyboard")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading)
                    
                    Button {
                        Task {
                            await sendQuickReply(.heart)
                        }
                    } label: {
                        Text("❤️")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
        }
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await loadMessages()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showingQuickReplies) {
            QuickRepliesView(threadId: thread.id) {
                Task {
                    await loadMessages()
                }
            }
        }
        .sheet(isPresented: $showingTextInput) {
            TextInputView(threadId: thread.id) {
                Task {
                    await loadMessages()
                }
            }
        }
        .task {
            await loadMessages()
        }
    }
    
    private func loadMessages() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkManager.fetchMessages(threadId: thread.id, limit: 50)
            messages = response.messages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func sendQuickReply(_ type: QuickReplyType) async {
        do {
            _ = try await networkManager.sendQuickReply(threadId: thread.id, replyType: type)
            await loadMessages()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ThreadView(thread: Thread(
            id: "1",
            title: "john_doe",
            usernames: ["john_doe"],
            lastMessage: "Hey there!",
            timestamp: Date().timeIntervalSince1970 * 1000,
            unreadCount: 0,
            isGroup: false
        ))
    }
}
