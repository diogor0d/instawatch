import ClockKit
import SwiftUI
import WidgetKit

struct UnreadCountComplication: Widget {
    let kind: String = "UnreadCountComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UnreadCountProvider()) { entry in
            UnreadCountComplicationView(entry: entry)
        }
        .configurationDisplayName("Instagram DM")
        .description("Shows unread message count")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

struct UnreadCountEntry: TimelineEntry {
    let date: Date
    let unreadCount: Int
    let isPlaceholder: Bool
}

struct UnreadCountProvider: TimelineProvider {
    func placeholder(in context: Context) -> UnreadCountEntry {
        UnreadCountEntry(date: Date(), unreadCount: 3, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (UnreadCountEntry) -> ()) {
        let entry = UnreadCountEntry(date: Date(), unreadCount: 2, isPlaceholder: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UnreadCountEntry>) -> ()) {
        Task {
            do {
                let unreadData = try await NetworkManager.shared.fetchUnreadCount()
                let entry = UnreadCountEntry(
                    date: Date(),
                    unreadCount: unreadData.unreadCount,
                    isPlaceholder: false
                )
                
                // Update every 15 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                // Fallback entry on error
                let entry = UnreadCountEntry(date: Date(), unreadCount: 0, isPlaceholder: false)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
}

struct UnreadCountComplicationView: View {
    let entry: UnreadCountEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryCorner:
            cornerView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }
    
    private var circularView: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
            
            VStack(spacing: 1) {
                Image(systemName: "message.fill")
                    .font(.caption2)
                    .foregroundColor(.white)
                
                if entry.unreadCount > 0 {
                    Text("\(entry.unreadCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var rectangularView: some View {
        HStack {
            Image(systemName: "message.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Instagram")
                    .font(.caption)
                    .fontWeight(.medium)
                
                if entry.unreadCount > 0 {
                    Text("\(entry.unreadCount) unread")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("No new messages")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    private var cornerView: some View {
        HStack {
            Image(systemName: "message.fill")
                .foregroundColor(.blue)
            
            if entry.unreadCount > 0 {
                Text("\(entry.unreadCount)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }
    
    private var inlineView: some View {
        HStack {
            Image(systemName: "message.fill")
            
            if entry.unreadCount > 0 {
                Text("\(entry.unreadCount) unread messages")
            } else {
                Text("No new messages")
            }
        }
    }
}

#Preview("Circular") {
    UnreadCountComplicationView(entry: UnreadCountEntry(date: Date(), unreadCount: 3, isPlaceholder: false))
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
}

#Preview("Rectangular") {
    UnreadCountComplicationView(entry: UnreadCountEntry(date: Date(), unreadCount: 2, isPlaceholder: false))
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
}
