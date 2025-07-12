import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    private var isFromMe: Bool {
        message.isFromMe ?? false
    }
    
    var body: some View {
        HStack {
            if isFromMe {
                Spacer(minLength: 20)
            }
            
            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if message.contentType != "text" {
                        Text(message.icon)
                            .font(.caption)
                    }
                    
                    Text(message.displayText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isFromMe ? Color.blue : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(isFromMe ? .white : .primary)
                }
                
                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isFromMe {
                Spacer(minLength: 20)
            }
        }
    }
    
    private func timeString(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 8) {
        MessageBubbleView(message: Message(
            id: "1",
            user: "other_user",
            timestamp: Date().timeIntervalSince1970 * 1000,
            type: "text",
            text: "Hey! How are you doing?",
            displayText: "Hey! How are you doing?",
            contentType: "text",
            icon: "💬",
            isFromMe: false,
            mediaType: nil,
            hasMedia: nil,
            duration: nil,
            linkTitle: nil
        ))
        
        MessageBubbleView(message: Message(
            id: "2",
            user: "me",
            timestamp: Date().timeIntervalSince1970 * 1000,
            type: "text",
            text: "I'm doing great, thanks!",
            displayText: "I'm doing great, thanks!",
            contentType: "text",
            icon: "💬",
            isFromMe: true,
            mediaType: nil,
            hasMedia: nil,
            duration: nil,
            linkTitle: nil
        ))
        
        MessageBubbleView(message: Message(
            id: "3",
            user: "other_user",
            timestamp: Date().timeIntervalSince1970 * 1000,
            type: "media",
            text: "[Image]",
            displayText: "📷 Photo",
            contentType: "media",
            icon: "📷",
            isFromMe: false,
            mediaType: "photo",
            hasMedia: true,
            duration: nil,
            linkTitle: nil
        ))
    }
    .padding()
}
