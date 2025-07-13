import Foundation

// MARK: - Thread Models
struct Thread: Codable, Identifiable {
    let id: String
    let title: String
    let usernames: [String]
    let lastMessage: String
    let timestamp: String?
    let unreadCount: Int
    let isGroup: Bool
    
    var formattedTime: String {
        guard let timestampString = timestamp,
              let timestampDouble = Double(timestampString) else { return "" }
        let date = Date(timeIntervalSince1970: timestampDouble / 1000)
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }
        
        return formatter.string(from: date)
    }
}

// MARK: - Message Models
struct Message: Codable, Identifiable {
    let id: String
    let user: Int
    let timestamp: String
    let type: String
    let text: String?
    let displayText: String
    let contentType: String
    let icon: String
    let senderName: String        // ADDED
    let senderUsername: String?   // ADDED
    let senderProfilePic: String? // ADDED
    
    // Optional fields that may or may not be present
    let mediaType: String?
    let hasMedia: Bool?
    let duration: Double?
    let linkTitle: String?
    
    var isFromMe: Bool {
        return String(user) == InstagramAPIService.shared.currentUserId
    }
    
    var formattedTime: String {
        guard let timestampDouble = Double(timestamp) else { return "" }
        let date = Date(timeIntervalSince1970: timestampDouble / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct ThreadResponse: Codable {
    let messages: [Message]
    let total: Int
    let hasMore: Bool
    let requestedLimit: Int
}

struct SendMessageResponse: Codable {
    let success: Bool
}

// MARK: - Watch Models
struct WatchThreadSummary: Codable {
    let threadId: String
    let messageCount: Int
    let recentMessages: [WatchMessage]
    let hasMore: Bool
}

struct WatchMessage: Codable, Identifiable {
    let id: String
    let displayText: String
    let icon: String
    let timestamp: String
    let isFromMe: Bool
    
    var formattedTime: String {
        guard let timestampDouble = Double(timestamp) else { return "" }
        let date = Date(timeIntervalSince1970: timestampDouble / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct UnreadCountResponse: Codable {
    let unreadCount: Int
    let totalThreads: Int
    let timestamp: TimeInterval
}

struct QuickReplyResponse: Codable {
    let success: Bool
    let sentMessage: String
}

// MARK: - Error Handling
enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError:
            return "Server error occurred"
        case .decodingError:
            return "Failed to decode server response"
        case .networkError:
            return "Network connection failed"
        }
    }
}

struct UserInfo: Codable {
    let userId: String
    let username: String
}