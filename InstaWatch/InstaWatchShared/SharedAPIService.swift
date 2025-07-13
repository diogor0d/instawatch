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
            throw error
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
            throw error
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
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                throw SharedAPIError.serverError
            }
            
            let result = try JSONDecoder().decode(SharedSendMessageResponse.self, from: data)
            if !result.success {
                throw SharedAPIError.serverError
            }
        } catch {
            if error is DecodingError {
                throw SharedAPIError.decodingError
            }
            throw error
        }
    }
}