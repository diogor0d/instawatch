import Foundation
import Combine

public class SharedAPIService: ObservableObject {
    public static let shared = SharedAPIService()
    
    private let baseURL = "http://192.168.1.200:3000"
    private let session = URLSession.shared
    
    @Published public var currentUserId: String = ""
    
    public init() {
        currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? ""
    }
    
    public func setCurrentUserId(_ userId: String) {
        currentUserId = userId
        UserDefaults.standard.set(userId, forKey: "currentUserId")
    }
    
    public func getCurrentUser() async throws -> SharedUserInfo {
        guard let url = URL(string: "\(baseURL)/me") else {
            throw SharedAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                throw SharedAPIError.serverError
            }
            
            return try JSONDecoder().decode(SharedUserInfo.self, from: data)
        } catch {
            if error is DecodingError {
                throw SharedAPIError.decodingError
            }
            throw error
        }
    }
    
    public func getInbox() async throws -> [SharedThread] {
        guard let url = URL(string: "\(baseURL)/inbox") else {
            throw SharedAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                throw SharedAPIError.serverError
            }
            
            return try JSONDecoder().decode([SharedThread].self, from: data)
        } catch {
            if error is DecodingError {
                throw SharedAPIError.decodingError
            }
            throw SharedAPIError.networkError
        }
    }
    
    public func getThread(id: String, limit: Int = 20) async throws -> SharedThreadResponse {
        guard let url = URL(string: "\(baseURL)/thread/\(id)?limit=\(limit)") else {
            throw SharedAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                throw SharedAPIError.serverError
            }
            
            return try JSONDecoder().decode(SharedThreadResponse.self, from: data)
        } catch {
            if error is DecodingError {
                throw SharedAPIError.decodingError
            }
            throw SharedAPIError.networkError
        }
    }
    
    public func sendMessage(threadId: String, message: String) async throws {
        guard let url = URL(string: "\(baseURL)/thread/\(threadId)/send") else {
            throw SharedAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["message": message]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw SharedAPIError.serverError
        }
    }
}

// MARK: - Shared Models (Copy from your SharedModels.swift in framework)
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