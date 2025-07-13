import SwiftUI

struct ThreadRowView: View {
    let thread: Thread
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile indicator
            Circle()
                .fill(thread.isGroup ? Color.blue : Color.green)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(thread.isGroup ? "👥" : "👤")
                        .font(.title2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if thread.unreadCount > 0 {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                    
                    Text(thread.formattedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(thread.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}