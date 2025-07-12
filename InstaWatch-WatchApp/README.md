# InstaWatch - Personal Apple Watch Instagram DM Client

A personal Apple Watch app for managing Instagram Direct Messages. This is a **personal-use only** app that connects to your Node.js backend with enhanced features and shortcuts.

## � Personal Features

- **Inbox View**: Browse Instagram DM threads
- **Message Reading**: View individual conversations
- **Quick Replies**: Send predefined responses instantly
- **Text Input**: Send custom messages
- **Watch Complications**: Show unread count on watch face
- **Settings**: Configure backend server URL

## 📱 Requirements

- **watchOS 9.0+**
- **iOS 16.0+** (companion app)
- **Xcode 14.0+**
- **Node.js backend** (see backend folder)

## 🚀 Setup Instructions

### 1. Backend Setup

Make sure your Node.js backend is running (see the backend project in the parent directory).

### 2. Xcode Project Setup

1. **Open Xcode**
2. **Create New Project**:

   - Choose "Watch App"
   - Product Name: "InstaWatch"
   - Interface: SwiftUI
   - Language: Swift

3. **Add Files to Project**:

   - Copy all `.swift` files from this directory into your Xcode project
   - Organize them into appropriate groups:
     - `Models/` - Data models
     - `Views/` - SwiftUI views
     - `Services/` - Network manager
     - `Complications/` - Watch face complications

4. **Configure Info.plist**:
   Add network permissions for HTTP requests:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

### 3. Network Configuration

1. **Find Your Computer's IP**:

   ```bash
   # On macOS/Linux
   ifconfig | grep "inet "

   # On Windows
   ipconfig
   ```

2. **Update Backend URL**:
   - In the watch app, go to Settings
   - Enter your computer's IP: `http://YOUR_IP:3000`
   - Example: `http://192.168.1.100:3000`

## 📂 Project Structure

```
InstaWatch-Watch/
├── InstaWatchApp.swift           # Main app entry point
├── Models/
│   └── Models.swift              # Data models matching backend API
├── Views/
│   ├── InboxView.swift          # Main inbox listing
│   ├── ThreadView.swift         # Individual conversation
│   ├── ThreadRowView.swift      # Thread list item
│   ├── MessageBubbleView.swift  # Message display
│   ├── QuickRepliesView.swift   # Quick reply buttons
│   ├── TextInputView.swift      # Custom message input
│   └── SettingsView.swift       # App configuration
├── Services/
│   └── NetworkManager.swift     # API communication
└── Complications/
    └── UnreadCountComplication.swift # Watch face widget
```

## 🔗 API Endpoints Used

- `GET /inbox` - Fetch DM threads
- `GET /thread/:id` - Fetch messages
- `POST /thread/:id/send` - Send custom message
- `POST /watch/thread/:id/quick-reply` - Send quick reply
- `GET /watch/unread-count` - Get unread count for complications

## 🎨 UI Components

### Inbox View

- Thread list with titles and last messages
- Pull-to-refresh functionality
- Unread indicators
- Settings access

### Thread View

- Message bubbles (sent/received)
- Quick action buttons
- Text input option
- Scroll to bottom anchor

### Quick Replies

- Grid layout of predefined responses
- Emoji + text descriptions
- One-tap sending

### Complications

- Circular, rectangular, corner, and inline variants
- Shows unread message count
- Updates every 15 minutes

## 🛠 Development Notes

### Watch-Specific Optimizations

- **Truncated text** for small screen
- **Large touch targets** for easy interaction
- **Minimal network payloads** for faster loading
- **Background refresh** support

### Network Handling

- **Error handling** with user-friendly messages
- **Loading states** for all async operations
- **Configurable backend URL** via settings

### Best Practices

- **SwiftUI navigation** with NavigationStack
- **Async/await** for network calls
- **@StateObject** for shared managers
- **Proper memory management**

## 🔧 Troubleshooting

### Common Issues

1. **"Cannot connect to server"**

   - Check backend is running on port 3000
   - Verify IP address in settings
   - Ensure both devices on same network

2. **"No data received"**

   - Check Instagram credentials in backend
   - Verify .env file configuration
   - Check backend logs for errors

3. **Complications not updating**
   - Reinstall app on watch
   - Check WidgetKit permissions
   - Verify network connectivity

### Debugging

- Use Xcode simulator for initial testing
- Check device console for error logs
- Monitor network requests in backend

## 📝 License

This project is for educational purposes. Instagram's terms of service apply to API usage.
