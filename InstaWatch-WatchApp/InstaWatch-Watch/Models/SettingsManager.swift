import Foundation

class SettingsManager: ObservableObject {
    @Published var backendURL: String = "http://localhost:3000"
    @Published var autoRefresh: Bool = true
    @Published var hapticFeedback: Bool = true
    @Published var showTimestamps: Bool = true
    @Published var refreshInterval: Int = 15 // seconds
    @Published var messageLimit: Int = 20
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        userDefaults.set(backendURL, forKey: "backendURL")
        userDefaults.set(autoRefresh, forKey: "autoRefresh")
        userDefaults.set(hapticFeedback, forKey: "hapticFeedback")
        userDefaults.set(showTimestamps, forKey: "showTimestamps")
        userDefaults.set(refreshInterval, forKey: "refreshInterval")
        userDefaults.set(messageLimit, forKey: "messageLimit")
    }
    
    private func loadSettings() {
        backendURL = userDefaults.string(forKey: "backendURL") ?? "http://localhost:3000"
        autoRefresh = userDefaults.bool(forKey: "autoRefresh")
        hapticFeedback = userDefaults.bool(forKey: "hapticFeedback") 
        showTimestamps = userDefaults.bool(forKey: "showTimestamps")
        refreshInterval = userDefaults.integer(forKey: "refreshInterval") == 0 ? 15 : userDefaults.integer(forKey: "refreshInterval")
        messageLimit = userDefaults.integer(forKey: "messageLimit") == 0 ? 20 : userDefaults.integer(forKey: "messageLimit")
    }
}
