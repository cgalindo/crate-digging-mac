# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CrateDigging is a macOS application for modifying Native Instruments Traktor NML files. The app allows users to manage their Traktor music collection, playlists, crates, and mixes across multiple Traktor versions.

## Build and Test Commands

### Building
```bash
# Build the main application
xcodebuild -workspace CrateDigging.xcworkspace -scheme CrateDigging -configuration Debug build

# Build the CrateFoundation package
xcodebuild -workspace CrateDigging.xcworkspace -scheme CrateFoundation -configuration Debug build
```

### Testing
```bash
# Run all tests
xcodebuild -workspace CrateDigging.xcworkspace -scheme CrateDigging test

# Run CrateFoundation package tests
xcodebuild -workspace CrateDigging.xcworkspace -scheme CrateFoundationTests test

# Run a specific test class
xcodebuild -workspace CrateDigging.xcworkspace -scheme CrateDigging test -only-testing:CrateDiggingTests/TraktorVersionTests

# Run a specific test method
xcodebuild -workspace CrateDigging.xcworkspace -scheme CrateDigging test -only-testing:CrateDiggingTests/TraktorVersionTests/testCompareVersions
```

## Architecture

### MVVM with Observation Framework

The app uses SwiftUI with an MVVM architecture pattern utilizing Swift's Observation framework:

- **ViewModels**: Always marked as `@Observable` and `@MainActor` to ensure UI operations on the main thread
- **ViewModel Instantiation**: ViewModels are instantiated in the view's `init()` using `@State` property wrapper, never `@StateObject` or `@ObservedObject`
- **Generic ViewModels**: ViewModels take service dependencies as type parameters (e.g., `ViewModel<FolderService>`)
- **View Logic**: All calculations for sizing, positioning, or formatting must be implemented in the ViewModel, not the View

### Module Structure

The codebase is organized into three main areas:

1. **CrateDigging/** - Main application code
   - **Core/** - Shared utilities, app entry point, and core services
     - `CrateDiggingApp.swift` - Main app entry point showing `HomeView`
     - **Software/** - Traktor-specific models and use cases
     - **Utility/** - File system, user defaults, error handling
     - **Views/** - Reusable UI components

   - **Features/** - Feature modules organized by domain
     - **Home/** - Navigation and main app shell
     - **Collection/** - Music collection management
     - **Crates/** - Crate organization
     - **Mixes/** - Mix/playlist history
     - **Settings/** - App configuration

   - **Playlist/** - Playlist parsing and XML handling

2. **Packages/CrateFoundation/** - Shared Swift package
   - **FolderManagement/** - Cross-platform folder selection and bookmarking
     - `FolderRepository` - Manages security-scoped bookmarks for folder access
     - `FolderPanel` - Presents native folder selection dialogs
     - `BookmarkStore` - Persists bookmarks using UserDefaults

3. **CrateDiggingTests/** - Unit tests for the main application

### File Organization Rules

**View and ViewModel Pairing:**
- Views with associated ViewModels must be in a dedicated folder
- Pattern: `ViewName/ViewName.swift` and `ViewName/ViewName+ViewModel.swift`
- Examples:
  - `PlaylistView/PlaylistView.swift`
  - `PlaylistView/PlaylistView+ViewModel.swift`

**Protocol and Implementation Pairing:**
- Protocols for dependencies are separated into their own files
- Pattern: `ServiceName/ServiceNameProtocol.swift` and `ServiceName/ServiceName.swift`
- Both files reside in the same folder named after the service

### Key Architectural Patterns

**Use Cases**: Business logic is encapsulated in use case objects following the callable pattern (`callAsFunction`). Example: `TraktorRootFolderUseCase` handles root folder validation, version detection, and bookmark persistence.

**Traktor Version Management**: The app supports multiple Traktor installations:
- Scans root folder for version folders matching pattern `Traktor X.X.X`
- Stores available versions in UserDefaults
- User selects which version's data to access
- See `TraktorVersion.swift:14` for version comparison logic

**Security-Scoped Bookmarks**: Folder access uses macOS security-scoped bookmarks (via `CrateFoundation/FolderRepository`) to maintain persistent access to user-selected folders across app launches.

**Error Handling**: Custom error types conform to `LocalizedError` for user-facing messages. Use `DisplayableError` for UI-presentable errors.

## Dependencies

- **XMLCoder** (0.17.1) - XML parsing for Traktor NML files
- **CrateFoundation** (local package) - Shared folder management utilities

## Platform Requirements

- macOS 13.0+
- Swift 6.0
- Xcode 15+
- UI Stack: SwiftUI preferred; bridge to UIKit via `*Representable` as needed
