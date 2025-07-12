import SwiftUI

struct QuickRepliesView: View {
    let threadId: String
    let onReplyTapped: () -> Void
    
    @StateObject private var networkManager = NetworkManager.shared
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    private let quickReplies = QuickReplyType.allCases
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(quickReplies, id: \.self) { reply in
                        Button {
                            Task {
                                await sendQuickReply(reply)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(reply.displayText)
                                    .font(.title2)
                                
                                Text(reply.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Quick Replies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
        }
    }
    
    private func sendQuickReply(_ type: QuickReplyType) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await networkManager.sendQuickReply(threadId: threadId, replyType: type)
            onReplyTapped()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    QuickRepliesView(threadId: "123") {
        print("Reply sent")
    }
}
