import Foundation
import Combine

class InstagramAPIService: ObservableObject {
    static let shared = InstagramAPIService()
    
    private let sharedService = SharedAPIService.shared
    
    @Published var currentUserId: String = ""
    
    private init() {
        currentUserId = sharedService.currentUserId
    }
    
    func setCurrentUserId(_ userId: String) {
        sharedService.setCurrentUserId(userId)
        currentUserId = userId
    }
    
    func getCurrentUser() async throws -> UserInfo {
        let sharedUser = try await sharedService.getCurrentUser()
        return UserInfo(userId: sharedUser.userId, username: sharedUser.username)
    }
    
    func getInbox() async throws -> [Thread] {
        let sharedThreads = try await sharedService.getInbox()
        return sharedThreads.map { sharedThread in
            Thread(
                id: sharedThread.id,
                title: sharedThread.title,
                usernames: sharedThread.usernames,
                lastMessage: sharedThread.lastMessage,
                timestamp: sharedThread.timestamp,
                unreadCount: sharedThread.unreadCount,
                isGroup: sharedThread.isGroup
            )
        }
    }
    
    func getThread(id: String, limit: Int = 20) async throws -> ThreadResponse {
        let sharedResponse = try await sharedService.getThread(id: id, limit: limit)
        return ThreadResponse(
            messages: sharedResponse.messages.map { sharedMessage in
                Message(
                    id: sharedMessage.id,
                    user: sharedMessage.user,
                    timestamp: sharedMessage.timestamp,
                    type: sharedMessage.type,
                    text: sharedMessage.text,
                    displayText: sharedMessage.displayText,
                    contentType: sharedMessage.contentType,
                    icon: sharedMessage.icon,
                    senderName: sharedMessage.senderName,
                    senderUsername: sharedMessage.senderUsername,
                    senderProfilePic: sharedMessage.senderProfilePic,
                    mediaType: sharedMessage.mediaType,
                    hasMedia: sharedMessage.hasMedia,
                    duration: sharedMessage.duration,
                    linkTitle: sharedMessage.linkTitle
                )
            },
            total: sharedResponse.total,
            hasMore: sharedResponse.hasMore,
            requestedLimit: sharedResponse.requestedLimit
        )
    }
    
    func sendMessage(threadId: String, message: String) async throws {
        try await sharedService.sendMessage(threadId: threadId, message: message)
    }
}