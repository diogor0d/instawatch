import SwiftUI

struct ThreadRowView: View {
    let thread: Thread
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(thread.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                if thread.unreadCount > 0 {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(thread.lastMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                if thread.isGroup {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let timestamp = thread.timestamp {
                    Text(timeAgoString(from: timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func timeAgoString(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h"
        } else {
            return "\(Int(interval / 86400))d"
        }
    }
}

#Preview {
    List {
        ThreadRowView(thread: Thread(
            id: "1",
            title: "john_doe",
            usernames: ["john_doe"],
            lastMessage: "Hey! How are you doing today?",
            timestamp: Date().timeIntervalSince1970 * 1000,
            unreadCount: 1,
            isGroup: false
        ))
        
        ThreadRowView(thread: Thread(
            id: "2",
            title: "sarah_smith + 2",
            usernames: ["sarah_smith", "mike_jones", "alex_brown"],
            lastMessage: "📷 Photo",
            timestamp: (Date().timeIntervalSince1970 - 3600) * 1000,
            unreadCount: 0,
            isGroup: true
        ))
    }
}
