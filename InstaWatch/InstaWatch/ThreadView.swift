import SwiftUI

struct ThreadView: View {
    let thread: Thread
    @StateObject private var apiService = InstagramAPIService.shared
    @State private var messages: [Message] = []
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @FocusState private var isMessageFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages.reversed()) { message in
                            MessageBubbleView(message: message, thread: thread)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            // Message input
            HStack {
                TextField("Message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($isMessageFieldFocused)
                    .lineLimit(1...4)
                
                Button(action: sendMessage) {
                    if isSending {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Refresh") {
                    Task {
                        await loadMessages()
                    }
                }
            }
        }
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
            let response = try await apiService.getThread(id: thread.id)
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
        isMessageFieldFocused = false
        
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
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: Message
    let thread: Thread
    
    var body: some View {
        HStack {
            if message.isFromMe {
                Spacer()
                messageBubble
                    .background(Color.blue)
                    .foregroundColor(.white)
            } else {
                messageBubble
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
    
    private var messageBubble: some View {
        HStack(spacing: 8) {
            if !message.isFromMe {
                Text(message.icon)
                    .font(.title2)
            }
            
            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                // Show sender name in group chats
                if thread.isGroup && !message.isFromMe {
                    Text(message.senderName)  // UPDATED: Use actual sender name
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(message.displayText)
                    .font(.body)
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}