//
//  TraktorPanelItem.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 9/27/25.
//

import Foundation
import CrateFoundation

/// An enum that defines the different types of file/folder access requests needed for Traktor integration.
/// Conforms to `PanelItem` protocol to configure file access panels (NSOpenPanel) for requesting
/// user permission to access Traktor-related files and folders on macOS.
/// Used to request access to:
/// - The Native Instruments root folder (where Traktor is installed)
/// - The History folder (contains Traktor's history playlists)
/// - The collection.nml file (Traktor's main collection database)
enum TraktorPanelItem: PanelItem, CaseIterable {
    
    /// Requests access to the Native Instruments root folder where Traktor is installed.
    /// This folder typically contains Traktor's application data and configuration.
    case rootFolder
    
    /// Requests access to the History folder which contains Traktor's history playlists.
    /// These playlists track the user's mixing history.
    case historyFolder
    
    /// Requests access to the collection.nml file, which is Traktor's main collection database
    /// containing all track metadata and library information.
    case collection
    
    /// The main title displayed in the file access panel dialog.
    /// Provides context to the user about what access is being requested.
    var title: String {
        switch self {
        case .rootFolder:
            return "Crate Digging needs access to the Native Instruments folder"
        case .historyFolder:
            return "Crate Digging needs access to the History folder"
        case .collection:
            return "Crate Digging needs access to collection"
        }
    }
    
    /// The detailed message displayed in the file access panel dialog.
    /// Provides instructions to the user on what to select in the file picker.
    var message: String {
        switch self {
        case .rootFolder:
            return "Please select the Native Instruments folder to grant access."
        case .historyFolder:
            return "Please select the History folder to grant access."
        case .collection:
            return "Please select the collection.nml file to grant access."
        }
    }
    
    /// The text displayed on the confirmation button in the file access panel.
    /// This is the action button that grants the requested access.
    var prompt: String {
        return "Grant Access"
    }
    
    /// The initial directory URL shown when the file access panel opens.
    /// Defaults to the user's Documents directory as a starting point for navigation.
    var directoryURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// Whether the file access panel allows selecting directories.
    /// Returns `true` for rootFolder and historyFolder (which are folders),
    /// and `false` for collection (which is a file).
    var canChooseDirectories: Bool {
        switch self {
        case .rootFolder, .historyFolder:
            return true
        case .collection:
            return false
        }
    }
    
    /// Whether the file access panel allows selecting files.
    /// Returns `false` for rootFolder and historyFolder (which are folders),
    /// and `true` for collection (which is a file).
    var canChooseFiles: Bool {
        switch self {
        case .rootFolder, .historyFolder:
            return false
        case .collection:
            return true
        }
    }
    
    /// Whether the file access panel allows selecting multiple items at once.
    /// Always returns `false` as each panel item represents a single access request.
    var allowsMultipleSelection: Bool {
        return false
    }
    
    /// Whether the file access panel allows creating new directories.
    /// Always returns `false` as we only need to access existing Traktor folders/files.
    var cancreateDirectories: Bool {
        return false
    }
    
    /// The unique key used to store the selected URL in persistent storage (e.g., UserDefaults).
    /// Each case has a distinct key to separately store its granted access URL.
    var storeKey: String {
        switch self {
        case .rootFolder:
            return "traktor.rootFolder"
        case .historyFolder:
            return "traktor.historyFolder"
        case .collection:
            return "traktor.collection"
        }
    }
}
