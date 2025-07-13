import SwiftUI

struct WatchThreadView: View {
    let thread: SharedThread
    @StateObject private var apiService = SharedAPIService.shared
    @State private var messages: [SharedMessage] = []
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(messages.reversed()) { message in
                            WatchMessageBubbleView(message: message, thread: thread)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }
                
                            // Message input section - SIMPLIFIED
            HStack(spacing: 6) {
                TextField("Message...", text: $messageText, axis: .vertical)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .lineLimit(1...3)
                    .font(.caption)
                
                Button(action: sendMessage) {
                    if isSending {
                        ProgressView()
                            .scaleEffect(0.5)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.caption2)
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                .buttonStyle(.borderedProminent)
                .frame(width: 28, height: 28)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
        .task {
            await loadMessages()
        }
    }
    
    private func loadMessages() async {
        isLoading = true
        do {
            let response = try await apiService.getThread(id: thread.id, limit: 10) // Limit for Watch
            messages = response.messages
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        isSending = true
        
        Task {
            do {
                try await apiService.sendMessage(threadId: thread.id, message: messageToSend)
                await loadMessages()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isSending = false
        }
    }
    
    private func sendQuickReply(_ text: String) {
        isSending = true
        
        Task {
            do {
                try await apiService.sendMessage(threadId: thread.id, message: text)
                await loadMessages()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isSending = false
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct WatchMessageBubbleView: View {
    let message: SharedMessage
    let thread: SharedThread
    
    private var isFromMe: Bool {
        return String(message.user) == SharedAPIService.shared.currentUserId
    }
    
    var body: some View {
        HStack {
            if isFromMe {
                Spacer()
                messageBubble
                    .background(Color.blue)
                    .foregroundColor(.white)
            } else {
                messageBubble
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
    
    private var messageBubble: some View {
        VStack(alignment: isFromMe ? .trailing : .leading, spacing: 2) {
            // Show sender name in group chats
            if thread.isGroup && !isFromMe {
                Text(message.senderName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                if !isFromMe {
                    Text(message.icon)
                        .font(.caption)
                }
                
                Text(message.displayText)
                    .font(.caption)
                    .lineLimit(3)
            }
            
            Text(message.formattedTime)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}