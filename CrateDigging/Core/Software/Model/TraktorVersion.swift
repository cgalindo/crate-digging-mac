//
//  TraktorVersion.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

/// Represents a specific version of Traktor software installed on the system.
/// Used to identify and manage multiple Traktor installations, allowing users to select
/// which version's data (collection, playlists, etc.) they want to access.
/// Supports semantic version comparison (e.g., "4.1.1" vs "4.0.5").
struct TraktorVersion: Codable, Identifiable, Comparable, Equatable {
    /// Unique identifier for this Traktor version, computed from the folder name.
    /// Used to uniquely identify versions in collections and for selection purposes.
    /// Satisfies the `Identifiable` protocol requirement.
    var id: String {
        folderName
    }
    
    /// The semantic version string (e.g., "4.1.1", "3.4.0").
    /// Used for display and version comparison.
    let version: String
    
    /// The name of the folder where this Traktor version's data is stored.
    /// Typically follows a pattern like "Traktor 4.1.1" or similar.
    /// Used to build file system paths and as the unique identifier.
    let folderName: String
    
    /// Whether this version is currently selected by the user.
    /// Used to track the active Traktor version for data access operations.
    let isSelected: Bool
    
    /// Creates a new TraktorVersion instance.
    /// - Parameters:
    ///   - version: The semantic version string (e.g., "4.1.1")
    ///   - folderName: The name of the folder containing this version's data
    ///   - isSelected: Whether this version is currently selected (defaults to `false`)
    init(
        version: String,
        folderName: String,
        isSelected: Bool = false
    ) {
        self.version = version
        self.folderName = folderName
        self.isSelected = isSelected
    }
    
    /// Compares two semantic version strings and returns their relative ordering.
    /// Performs component-by-component comparison (major.minor.patch).
    /// - Parameters:
    ///   - version1: First version string to compare
    ///   - version2: Second version string to compare
    /// - Returns: 
    ///   - `-1` if version1 < version2
    ///   - `1` if version1 > version2
    ///   - `0` if version1 == version2
    /// - Note: Missing components are treated as 0 (e.g., "4.1" == "4.1.0")
    static func compareVersions(_ version1: String, _ version2: String) -> Int {
        let components1 = version1.split(separator: ".").compactMap { Int($0) }
        let components2 = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxCount = max(components1.count, components2.count)
        
        for index in 0..<maxCount {
            let value1 = index < components1.count ? components1[index] : 0
            let value2 = index < components2.count ? components2[index] : 0
            
            if value1 < value2 {
                return -1
            } else if value1 > value2 {
                return 1
            }
        }
        
        return 0
    }
}

/// Custom less-than operator for comparing TraktorVersion instances.
/// Enables `Comparable` conformance by comparing version strings semantically.
/// Example: `TraktorVersion(version: "4.1.1", ...) < TraktorVersion(version: "4.0.5", ...)` returns `false`
func < (lhs: TraktorVersion, rhs: TraktorVersion) -> Bool {
    TraktorVersion.compareVersions(lhs.version, rhs.version) < 0
}

/// A container for managing multiple TraktorVersion instances.
/// Maintains a collection of available Traktor versions and tracks which one is selected.
/// Provides convenient access to the currently selected version, falling back to the latest version if none is explicitly selected.
struct TraktorVersions: Codable {
    /// Array of all available Traktor versions found on the system.
    var versions: [TraktorVersion]
    
    /// The ID of the currently selected Traktor version, if any.
    /// When `nil`, the latest version is used as the default.
    var selectedVersionId: String?
    
    /// Returns the currently selected Traktor version.
    /// If a version is explicitly selected via `selectedVersionId`, returns that version.
    /// Otherwise, returns the latest version (highest semantic version number) from the `versions` array.
    /// Returns `nil` if the `versions` array is empty.
    var selectedVersion: TraktorVersion? {
        if let selectedId = selectedVersionId,
           let foundVersion = versions.first(where: { $0.id == selectedId }) {
            return foundVersion
        }
        return versions.max()
    }
}


