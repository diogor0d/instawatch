import Foundation

// MARK: - Shared Thread Models
public struct SharedThread: Codable, Identifiable {
    public let id: String
    public let title: String
    public let usernames: [String]
    public let lastMessage: String
    public let timestamp: String?
    public let unreadCount: Int
    public let isGroup: Bool
    
    public init(id: String, title: String, usernames: [String], lastMessage: String, timestamp: String?, unreadCount: Int, isGroup: Bool) {
        self.id = id
        self.title = title
        self.usernames = usernames
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.unreadCount = unreadCount
        self.isGroup = isGroup
    }
    
    public var formattedTime: String {
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

// MARK: - Shared Message Models
public struct SharedMessage: Codable, Identifiable {
    public let id: String
    public let user: Int
    public let timestamp: String
    public let type: String
    public let text: String?
    public let displayText: String
    public let contentType: String
    public let icon: String
    public let senderName: String
    public let senderUsername: String?
    public let senderProfilePic: String?
    public let mediaType: String?
    public let hasMedia: Bool?
    public let duration: Double?
    public let linkTitle: String?
    
    public init(id: String, user: Int, timestamp: String, type: String, text: String?, displayText: String, contentType: String, icon: String, senderName: String, senderUsername: String?, senderProfilePic: String?, mediaType: String? = nil, hasMedia: Bool? = nil, duration: Double? = nil, linkTitle: String? = nil) {
        self.id = id
        self.user = user
        self.timestamp = timestamp
        self.type = type
        self.text = text
        self.displayText = displayText
        self.contentType = contentType
        self.icon = icon
        self.senderName = senderName
        self.senderUsername = senderUsername
        self.senderProfilePic = senderProfilePic
        self.mediaType = mediaType
        self.hasMedia = hasMedia
        self.duration = duration
        self.linkTitle = linkTitle
    }
    
    public var formattedTime: String {
        guard let timestampDouble = Double(timestamp) else { return "" }
        let date = Date(timeIntervalSince1970: timestampDouble / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Shared Response Models
public struct SharedThreadResponse: Codable {
    public let messages: [SharedMessage]
    public let total: Int
    public let hasMore: Bool
    public let requestedLimit: Int
    
    public init(messages: [SharedMessage], total: Int, hasMore: Bool, requestedLimit: Int) {
        self.messages = messages
        self.total = total
        self.hasMore = hasMore
        self.requestedLimit = requestedLimit
    }
}

public struct SharedUserInfo: Codable {
    public let userId: String
    public let username: String
    
    public init(userId: String, username: String) {
        self.userId = userId
        self.username = username
    }
}

public struct SharedSendMessageResponse: Codable {
    public let success: Bool
    
    public init(success: Bool) {
        self.success = success
    }
}

// MARK: - Shared Error Types
public enum SharedAPIError: Error, LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    case networkError
    
    public var errorDescription: String? {
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