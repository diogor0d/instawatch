import Foundation

// MARK: - Thread Models
struct Thread: Identifiable, Codable {
    let id: String
    let title: String
    let usernames: [String]
    let lastMessage: String
    let timestamp: TimeInterval?
    let unreadCount: Int
    let isGroup: Bool
}

// MARK: - Message Models
struct Message: Identifiable, Codable {
    let id: String
    let user: String
    let timestamp: TimeInterval
    let type: String
    let text: String
    let displayText: String
    let contentType: String
    let icon: String
    let isFromMe: Bool?
    
    // Optional properties for different message types
    let mediaType: String?
    let hasMedia: Bool?
    let duration: Double?
    let linkTitle: String?
}

struct MessageResponse: Codable {
    let messages: [Message]
    let total: Int
    let hasMore: Bool
    let requestedLimit: Int
}

// MARK: - Thread Summary for Watch
struct ThreadSummary: Codable {
    let threadId: String
    let messageCount: Int
    let recentMessages: [WatchMessage]
    let hasMore: Bool
}

struct WatchMessage: Identifiable, Codable {
    let id: String
    let displayText: String
    let icon: String
    let timestamp: TimeInterval
    let isFromMe: Bool
}

// MARK: - Quick Reply Response
struct QuickReplyResponse: Codable {
    let success: Bool
    let sentMessage: String
}

// MARK: - Unread Count for Complications
struct UnreadCount: Codable {
    let unreadCount: Int
    let totalThreads: Int
    let timestamp: TimeInterval
}

// MARK: - API Error Response
struct APIError: Codable {
    let error: String
}

// MARK: - Personal Use Models

struct PersonalStatus {
    let unreadCount: Int
    let totalThreads: Int
    let lastUpdate: Date
    let mostRecentThread: String?
}

// MARK: - Enhanced Quick Reply Types for Personal Use
enum QuickReplyType: String, CaseIterable {
    case thumbsUp = "thumbs_up"
    case heart = "heart"
    case ok = "ok"
    case thanks = "thanks"
    case yes = "yes"
    case no = "no"
    case busy = "busy"
    
    // Personal shortcuts
    case brb = "brb"
    case onMyWay = "on_my_way"
    case lol = "lol"
    case wtf = "wtf"
    
    var displayText: String {
        switch self {
        case .thumbsUp: return "👍"
        case .heart: return "❤️"
        case .ok: return "OK"
        case .thanks: return "Thanks!"
        case .yes: return "Yes"
        case .no: return "No"
        case .busy: return "Busy"
        case .brb: return "BRB"
        case .onMyWay: return "On my way"
        case .lol: return "😂"
        case .wtf: return "WTF"
        }
    }
    
    var icon: String {
        switch self {
        case .thumbsUp: return "👍"
        case .heart: return "❤️"
        case .ok: return "✅"
        case .thanks: return "🙏"
        case .yes: return "✅"
        case .no: return "❌"
        case .busy: return "🚫"
        case .brb: return "⏰"
        case .onMyWay: return "🏃"
        case .lol: return "😂"
        case .wtf: return "😱"
        }
    }
}
