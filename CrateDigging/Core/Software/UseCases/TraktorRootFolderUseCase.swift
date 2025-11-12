//
//  TraktorRootFolderUseCase.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation
import CrateFoundation

struct TraktorRootFolderUseCase: RootFolderUseCase {
    private let folderRepository: any FolderRepository
    private let fileSystem: any FileSystem
    private let userDefaults: any UserDefaultsStorage
    
    private let versionsKey = "traktor.versions"
    private let selectedVersionKey = "traktor.selectedVersion"
    
    init(
        folderRepository: any FolderRepository = DefaultFolderRepository(),
        fileSystem: (any FileSystem)? = nil,
        userDefaults: any UserDefaultsStorage = UserDefaultsStore()
    ) {
        self.folderRepository = folderRepository
        self.fileSystem = fileSystem ?? DefaultFileSystem()
        self.userDefaults = userDefaults
    }
    
    func callAsFunction(_ rootFolderURL: URL) async throws {
        // Find all Traktor version folders
        let versions = try findTraktorVersions(in: rootFolderURL)
        
        // Save versions to UserDefaults
        try saveVersions(versions)
        
        // Get selected version - use the one from UserDefaults or default to latest
        let selectedVersionId = loadSelectedVersionId() ?? versions.max()?.id
        guard let selectedVersion = versions.first(where: { $0.id == selectedVersionId }) ?? versions.max() ?? versions.first else {
            return
        }
        
        // Build paths for history and collection
        let historyPath = rootFolderURL.appendingPathComponent(selectedVersion.folderName).appendingPathComponent("History")
        let collectionPath = rootFolderURL.appendingPathComponent(selectedVersion.folderName).appendingPathComponent("collection.nml")
        
        // Verify paths exist
        guard fileSystem.fileExists(atPath: historyPath.path) else {
            throw TraktorRootFolderError.historyFolderNotFound
        }
        
        guard fileSystem.fileExists(atPath: collectionPath.path) else {
            throw TraktorRootFolderError.collectionFileNotFound
        }
        
        // Bookmark history folder and collection file
        let historyBookmark = Bookmark(url: historyPath, key: TraktorPanelItem.historyFolder.storeKey)
        let collectionBookmark = Bookmark(url: collectionPath, key: TraktorPanelItem.collection.storeKey)
        
        // TODO: Implement a batch save
        try await folderRepository.save(historyBookmark)
        try await folderRepository.save(collectionBookmark)
    }
    
    // MARK: - Private Methods
    
    private func findTraktorVersions(in rootFolder: URL) throws -> [TraktorVersion] {
        let contents = try fileSystem.contentsOfDirectory(
            at: rootFolder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: []
        )
        
        var versions: [TraktorVersion] = []
        let versionPattern = #"^Traktor (\d+\.\d+\.\d+)$"#
        
        for item in contents {
            guard fileSystem.isDirectory(atPath: item.path) else {
                continue
            }
            
            let folderName = item.lastPathComponent
            
            // Check if folder name matches "Traktor X.X.X" pattern
            if let regex = try? NSRegularExpression(pattern: versionPattern, options: []) {
                let nsString = folderName as NSString
                let results = regex.matches(in: folderName, options: [], range: NSRange(location: 0, length: nsString.length))
                
                if let match = results.first, match.numberOfRanges > 1 {
                    let versionRange = match.range(at: 1)
                    let version = nsString.substring(with: versionRange)
                    versions.append(TraktorVersion(version: version, folderName: folderName))
                }
            }
        }
        
        return versions.sorted(by: >) // Sort descending (latest first)
    }
    
    private func saveVersions(_ versions: [TraktorVersion]) throws {
        let selectedVersionId = loadSelectedVersionId() ?? versions.max()?.id
        
        var versionsToSave = versions
        // Mark the selected version
        if let selectedId = selectedVersionId,
           let index = versionsToSave.firstIndex(where: { $0.id == selectedId }) {
            versionsToSave[index] = TraktorVersion(
                version: versionsToSave[index].version,
                folderName: versionsToSave[index].folderName,
                isSelected: true
            )
        } else if let latestVersion = versions.max() {
            // Default to latest version
            if let index = versionsToSave.firstIndex(where: { $0.id == latestVersion.id }) {
                versionsToSave[index] = TraktorVersion(
                    version: versionsToSave[index].version,
                    folderName: versionsToSave[index].folderName,
                    isSelected: true
                )
            }
        }
        
        let traktorVersions = TraktorVersions(
            versions: versionsToSave,
            selectedVersionId: versionsToSave.first(where: { $0.isSelected })?.id
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(traktorVersions)
        userDefaults.set(data, forKey: versionsKey)
        
        if let selectedId = traktorVersions.selectedVersionId {
            userDefaults.set(selectedId, forKey: selectedVersionKey)
        }
    }
    
    private func loadSelectedVersionId() -> String? {
        return userDefaults.string(forKey: selectedVersionKey)
    }
}

enum TraktorRootFolderError: LocalizedError {
    case historyFolderNotFound
    case collectionFileNotFound
    
    var errorDescription: String? {
        switch self {
        case .historyFolderNotFound:
            return "History folder not found in the selected root folder"
        case .collectionFileNotFound:
            return "Collection file (collection.nml) not found in the selected root folder"
        }
    }
}

