import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @Environment(\.dismiss) private var dismiss
    @State private var tempURL: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Backend URL", text: $tempURL)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    Text("Example: http://192.168.1.100:3000")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Server Configuration")
                } footer: {
                    Text("Enter the IP address and port of your backend server")
                }
                
                Section {
                    HStack {
                        Text("Current URL")
                        Spacer()
                        Text(settingsManager.backendURL)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                } header: {
                    Text("Current Settings")
                }
                
                Section {
                    Button("Test Connection") {
                        testConnection()
                    }
                    .disabled(tempURL.isEmpty)
                    
                    Button("Set Local Network") {
                        tempURL = "http://192.168.1.100:3000"
                    }
                    
                    Button("Set Localhost") {
                        tempURL = "http://localhost:3000"
                    }
                } header: {
                    Text("Connection")
                }
                
                Section {
                    Toggle("Auto-refresh", isOn: $settingsManager.autoRefresh)
                    Toggle("Haptic feedback", isOn: $settingsManager.hapticFeedback)
                    Toggle("Show timestamps", isOn: $settingsManager.showTimestamps)
                } header: {
                    Text("Behavior")
                }
                
                Section {
                    Stepper("Refresh interval: \(settingsManager.refreshInterval)s", 
                           value: $settingsManager.refreshInterval, 
                           in: 5...60, 
                           step: 5)
                    
                    Stepper("Message limit: \(settingsManager.messageLimit)", 
                           value: $settingsManager.messageLimit, 
                           in: 10...100, 
                           step: 10)
                } header: {
                    Text("Performance")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .disabled(tempURL.isEmpty)
                }
            }
        }
        .onAppear {
            tempURL = settingsManager.backendURL
        }
    }
    
    private func saveSettings() {
        settingsManager.backendURL = tempURL
        settingsManager.saveSettings()
        dismiss()
    }
    
    private func testConnection() {
        // Quick and dirty connection test for personal use
        guard let url = URL(string: tempURL + "/watch/unread-count") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Connection successful - could add haptic feedback here
                    print("✅ Connection test successful")
                } else {
                    // Connection failed
                    print("❌ Connection test failed")
                }
            }
        }.resume()
    }
}

#Preview {
    SettingsView()
}
