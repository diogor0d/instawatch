<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# InstaWatch Apple Watch App

This is an Apple Watch app built with SwiftUI for viewing and responding to Instagram Direct Messages.

## Project Structure

- This project contains Swift/SwiftUI files for Apple Watch development
- The backend API is running on Node.js (separate project)
- Use Xcode for building and running the watch app
- Follow watchOS design guidelines and best practices

## Key Features

- Display Instagram DM inbox
- View individual message threads
- Send quick replies
- Show unread message count
- Watch complications support

## API Integration

- The app connects to a local Node.js backend
- Backend provides Instagram API integration
- All network calls should handle errors gracefully
- Use proper loading states for watch UI

## Development Notes

- Optimize for small watch screen sizes
- Use haptic feedback appropriately
- Support Digital Crown navigation
- Follow Apple's Human Interface Guidelines for watchOS
