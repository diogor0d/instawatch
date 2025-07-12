import Foundation
import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session = URLSession.shared
    private let settingsManager = SettingsManager()
    
    private var baseURL: String {
        return settingsManager.backendURL
    }
    
    init() {
        // Now uses SettingsManager for dynamic URL
    }
    
    // MARK: - Generic Network Request
    private func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                // Try to decode error message
                if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw NetworkError.apiError(errorResponse.error)
                }
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(responseType, from: data)
            
        } catch {
            if error is NetworkError {
                throw error
            }
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - API Endpoints
    
    /// Fetch inbox threads
    func fetchInbox() async throws -> [Thread] {
        return try await performRequest(
            endpoint: "/inbox",
            responseType: [Thread].self
        )
    }
    
    /// Fetch messages from a specific thread
    func fetchMessages(threadId: String, limit: Int = 20) async throws -> MessageResponse {
        return try await performRequest(
            endpoint: "/thread/\(threadId)?limit=\(limit)",
            responseType: MessageResponse.self
        )
    }
    
    /// Send a text message
    func sendMessage(threadId: String, message: String) async throws -> QuickReplyResponse {
        let body = ["message": message]
        let jsonData = try JSONEncoder().encode(body)
        
        return try await performRequest(
            endpoint: "/thread/\(threadId)/send",
            method: .POST,
            body: jsonData,
            responseType: QuickReplyResponse.self
        )
    }
    
    /// Send a quick reply
    func sendQuickReply(threadId: String, replyType: QuickReplyType) async throws -> QuickReplyResponse {
        let body = ["replyType": replyType.rawValue]
        let jsonData = try JSONEncoder().encode(body)
        
        return try await performRequest(
            endpoint: "/watch/thread/\(threadId)/quick-reply",
            method: .POST,
            body: jsonData,
            responseType: QuickReplyResponse.self
        )
    }
    
    /// Fetch thread summary (optimized for watch)
    func fetchThreadSummary(threadId: String) async throws -> ThreadSummary {
        return try await performRequest(
            endpoint: "/watch/thread/\(threadId)/summary",
            responseType: ThreadSummary.self
        )
    }
    
    /// Fetch unread count for complications
    func fetchUnreadCount() async throws -> UnreadCount {
        return try await performRequest(
            endpoint: "/watch/unread-count",
            responseType: UnreadCount.self
        )
    }
    
    // MARK: - Personal Use Shortcuts
    
    /// Quick thumbs up to most recent thread (personal shortcut)
    func quickThumbsUpToLastThread() async throws -> QuickReplyResponse {
        let threads = try await fetchInbox()
        guard let lastThread = threads.first else {
            throw NetworkError.apiError("No threads found")
        }
        return try await sendQuickReply(threadId: lastThread.id, replyType: .thumbsUp)
    }
    
    /// Send any quick reply to most recent thread
    func quickReplyToLastThread(_ replyType: QuickReplyType) async throws -> QuickReplyResponse {
        let threads = try await fetchInbox()
        guard let lastThread = threads.first else {
            throw NetworkError.apiError("No threads found")
        }
        return try await sendQuickReply(threadId: lastThread.id, replyType: replyType)
    }
    
    /// Test connection (for debugging)
    func testConnection() async -> Bool {
        do {
            _ = try await fetchUnreadCount()
            return true
        } catch {
            print("Connection test failed: \(error)")
            return false
        }
    }
    
    /// Get basic status for personal dashboard
    func getPersonalStatus() async throws -> PersonalStatus {
        async let unreadCount = fetchUnreadCount()
        async let inbox = fetchInbox()
        
        let count = try await unreadCount
        let threads = try await inbox
        
        return PersonalStatus(
            unreadCount: count.unreadCount,
            totalThreads: threads.count,
            lastUpdate: Date(),
            mostRecentThread: threads.first?.title
        )
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case decodingError(String)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .noData:
            return "No data received"
        }
    }
}

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    @Published var backendURL: String = "http://localhost:3000"
    
    private let userDefaults = UserDefaults.standard
    private let backendURLKey = "backendURL"
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        userDefaults.set(backendURL, forKey: backendURLKey)
    }
    
    private func loadSettings() {
        backendURL = userDefaults.string(forKey: backendURLKey) ?? "http://localhost:3000"
    }
}
