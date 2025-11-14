//
//  TraktorRootFolderUseCaseTests.swift
//  CrateDiggingTests
//
//  Created by Chris Galindo on 9/13/25.
//

import Testing
@testable import CrateDigging
@testable import CrateFoundation
import Foundation

struct TraktorRootFolderUseCaseTests {
    
    // MARK: - Success Cases
    
    @Test func processesRootFolderWithSingleVersion() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        let traktorFolder = rootFolder.appendingPathComponent("Traktor 4.1.1")
        let historyFolder = traktorFolder.appendingPathComponent("History")
        let collectionFile = traktorFolder.appendingPathComponent("collection.nml")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let directoryURLs = [traktorFolder]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            expectedFileExistsResult: true,
            expectedIsDirectoryResult: true
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock
        )
        
        // When
        try await useCase(rootFolder)
        
        // Then - Verify bookmarks were saved
        #expect(await bookmarkStoreMock.hasBookmark(for: TraktorPanelItem.historyFolder.storeKey))
        #expect(await bookmarkStoreMock.hasBookmark(for: TraktorPanelItem.collection.storeKey))
        
        // Verify saved URLs
        let savedHistoryURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.historyFolder.storeKey)
        let savedCollectionURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.collection.storeKey)
        
        #expect(savedHistoryURL == historyFolder)
        #expect(savedCollectionURL == collectionFile)
    }
    
    @Test func processesRootFolderWithMultipleVersions() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        let traktor405 = rootFolder.appendingPathComponent("Traktor 4.0.5")
        let traktor411 = rootFolder.appendingPathComponent("Traktor 4.1.1")
        let traktor352 = rootFolder.appendingPathComponent("Traktor 3.5.2")
        
        let historyFolder = traktor411.appendingPathComponent("History")
        let collectionFile = traktor411.appendingPathComponent("collection.nml")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let directoryURLs = [traktor405, traktor411, traktor352]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            expectedFileExistsResult: true,
            expectedIsDirectoryResult: true
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock
        )
        
        // When
        try await useCase(rootFolder)
        
        // Then - Should bookmark latest version (4.1.1)
        let savedHistoryURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.historyFolder.storeKey)
        let savedCollectionURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.collection.storeKey)
        
        #expect(savedHistoryURL == historyFolder)
        #expect(savedCollectionURL == collectionFile)
    }
    
    @Test func savesVersionsToUserDefaults() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        let traktor405 = rootFolder.appendingPathComponent("Traktor 4.0.5")
        let traktor411 = rootFolder.appendingPathComponent("Traktor 4.1.1")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        let userDefaultsMock = UserDefaultsStoreMock()
        
        let directoryURLs = [traktor405, traktor411]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            expectedFileExistsResult: true,
            expectedIsDirectoryResult: true
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock,
            userDefaults: userDefaultsMock
        )
        
        // When
        try await useCase(rootFolder)
        
        // Then - Verify versions were saved to UserDefaults
        guard let data = userDefaultsMock.data(forKey: "traktor.versions") else {
            Issue.record("Versions data not found in UserDefaults")
            return
        }
        
        let decoder = JSONDecoder()
        let traktorVersions = try decoder.decode(TraktorVersions.self, from: data)
        
        #expect(traktorVersions.versions.count == 2)
        #expect(traktorVersions.selectedVersionId == "Traktor 4.1.1") // Latest version should be selected
        
        // Verify version details
        let version411 = traktorVersions.versions.first { $0.version == "4.1.1" }
        #expect(version411 != nil)
        #expect(version411?.isSelected == true)
    }
    
    // MARK: - Error Cases
    
    @Test func throwsErrorWhenHistoryFolderNotFound() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        let traktorFolder = rootFolder.appendingPathComponent("Traktor 4.1.1")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let directoryURLs = [traktorFolder]
        
        // fileExists returns false for history folder
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            expectedFileExistsResult: false,
            expectedIsDirectoryResult: true
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock
        )
        
        // When & Then
        await #expect(throws: TraktorRootFolderError.historyFolderNotFound) {
            try await useCase(rootFolder)
        }
    }
    
    @Test func throwsErrorWhenCollectionFileNotFound() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        let traktorFolder = rootFolder.appendingPathComponent("Traktor 4.1.1")
        let historyFolder = traktorFolder.appendingPathComponent("History")
        let collectionFile = traktorFolder.appendingPathComponent("collection.nml")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let directoryURLs = [traktorFolder]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            fileExistsHandler: { path in
                if path == historyFolder.path {
                    return true
                }
                
                if path == collectionFile.path {
                    return false
                }
                
                return true
            },
            isDirectoryHandler: { _ in true }
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock
        )
        
        // When & Then - Should fail on collection check
        await #expect(throws: TraktorRootFolderError.collectionFileNotFound) {
            try await useCase(rootFolder)
        }
    }
    
    @Test func handlesFileSystemErrorWhenReadingDirectory() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: [],
            expectedContentsOfDirectoryError: testError,
            expectedFileExistsResult: false,
            expectedIsDirectoryResult: false
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock
        )
        
        // When & Then
        await #expect(throws: NSError.self) {
            try await useCase(rootFolder)
        }
    }
    
    @Test func handlesRepositoryErrorWhenSavingBookmark() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        let traktorFolder = rootFolder.appendingPathComponent("Traktor 4.1.1")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        await bookmarkStoreMock.setShouldThrowError(true, error: BookmarkError.emptyKey)
        
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let directoryURLs = [traktorFolder]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            expectedFileExistsResult: true,
            expectedIsDirectoryResult: true
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock
        )
        
        // When & Then
        await #expect(throws: BookmarkError.emptyKey) {
            try await useCase(rootFolder)
        }
    }
    
    // MARK: - Edge Cases
    
    @Test func throwsErrorWhenNoTraktorVersionsFound() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: [],
            expectedContentsOfDirectoryError: nil,
            expectedFileExistsResult: false,
            expectedIsDirectoryResult: false
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock
        )
        
        // When & Then - Should throw error when no versions found
        await #expect(throws: TraktorRootFolderError.noTraktorVersionsFound) {
            try await useCase(rootFolder)
        }
        
        // Verify no bookmarks were saved
        #expect(await bookmarkStoreMock.getStoredBookmarkCount() == 0)
    }
    
    @Test func ignoresNonTraktorFolders() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        let otherFolder = rootFolder.appendingPathComponent("Other Folder")
        let traktorFolder = rootFolder.appendingPathComponent("Traktor 4.1.1")
        let anotherApp = rootFolder.appendingPathComponent("Another App")
        
        let historyFolder = traktorFolder.appendingPathComponent("History")
        let collectionFile = traktorFolder.appendingPathComponent("collection.nml")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        let userDefaultsMock = UserDefaultsStoreMock()
        
        let directoryURLs = [otherFolder, traktorFolder, anotherApp]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            expectedFileExistsResult: true,
            expectedIsDirectoryResult: true
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock,
            userDefaults: userDefaultsMock
        )
        
        // When
        try await useCase(rootFolder)
        
        // Then - Should only process Traktor folder
        let savedHistoryURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.historyFolder.storeKey)
        let savedCollectionURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.collection.storeKey)
        
        #expect(savedHistoryURL == historyFolder)
        #expect(savedCollectionURL == collectionFile)
        
        // Verify only one version was saved
        guard let data = userDefaultsMock.data(forKey: "traktor.versions") else {
            Issue.record("Versions data not found in UserDefaults")
            return
        }
        
        let decoder = JSONDecoder()
        let traktorVersions = try decoder.decode(TraktorVersions.self, from: data)
        #expect(traktorVersions.versions.count == 1)
    }
    
    @Test func preservesPreviouslySelectedVersion() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        
        // Pre-populate UserDefaults with a selected version
        let existingVersions = [
            TraktorVersion(version: "4.0.5", folderName: "Traktor 4.0.5", isSelected: true),
            TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1", isSelected: false)
        ]
        let existingTraktorVersions = TraktorVersions(
            versions: existingVersions,
            selectedVersionId: "Traktor 4.0.5"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(existingTraktorVersions)
        let userDefaultsMock = UserDefaultsStoreMock()
        userDefaultsMock.set(data, forKey: "traktor.versions")
        userDefaultsMock.set("Traktor 4.0.5", forKey: "traktor.selectedVersion")
        
        let traktor405 = rootFolder.appendingPathComponent("Traktor 4.0.5")
        let traktor411 = rootFolder.appendingPathComponent("Traktor 4.1.1")
        
        let historyFolder = traktor405.appendingPathComponent("History")
        let collectionFile = traktor405.appendingPathComponent("collection.nml")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let directoryURLs = [traktor405, traktor411]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            expectedFileExistsResult: true,
            expectedIsDirectoryResult: true
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock,
            userDefaults: userDefaultsMock
        )
        
        // When
        try await useCase(rootFolder)
        
        // Then - Should use previously selected version (4.0.5)
        let savedHistoryURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.historyFolder.storeKey)
        let savedCollectionURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.collection.storeKey)
        
        #expect(savedHistoryURL == historyFolder)
        #expect(savedCollectionURL == collectionFile)
        
        // Verify selected version is preserved
        guard let updatedData = userDefaultsMock.data(forKey: "traktor.versions") else {
            Issue.record("Versions data not found in UserDefaults")
            return
        }
        
        let decoder = JSONDecoder()
        let updatedVersions = try decoder.decode(TraktorVersions.self, from: updatedData)
        let selectedVersion = updatedVersions.versions.first { $0.isSelected }
        #expect(selectedVersion?.folderName == "Traktor 4.0.5")
    }
    
    @Test func defaultsToLatestVersionWhenSelectedVersionMissing() async throws {
        // Given
        let rootFolder = URL(fileURLWithPath: "/test/root")
        
        // Pre-populate UserDefaults with a selected version that no longer exists
        let existingVersions = [
            TraktorVersion(version: "4.0.5", folderName: "Traktor 4.0.5", isSelected: true)
        ]
        let existingTraktorVersions = TraktorVersions(
            versions: existingVersions,
            selectedVersionId: "Traktor 4.0.5"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(existingTraktorVersions)
        let userDefaultsMock = UserDefaultsStoreMock()
        userDefaultsMock.set(data, forKey: "traktor.versions")
        userDefaultsMock.set("Traktor 4.0.5", forKey: "traktor.selectedVersion")
        
        let traktor411 = rootFolder.appendingPathComponent("Traktor 4.1.1")
        let historyFolder = traktor411.appendingPathComponent("History")
        let collectionFile = traktor411.appendingPathComponent("collection.nml")
        
        let bookmarkStoreMock = DefaultBookmarkStoreMock()
        let folderRepository = DefaultFolderRepository(bookmarkStore: bookmarkStoreMock)
        
        let directoryURLs = [traktor411]
        
        let fileSystemMock = DefaultFileSystemMock(
            expectedContentsOfDirectoryResult: directoryURLs,
            fileExistsHandler: { _ in true },
            isDirectoryHandler: { _ in true }
        )
        
        let useCase = TraktorRootFolderUseCase(
            folderRepository: folderRepository,
            fileSystem: fileSystemMock,
            userDefaults: userDefaultsMock
        )
        
        // When
        try await useCase(rootFolder)
        
        // Then - Should select the latest available version (4.1.1)
        let savedHistoryURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.historyFolder.storeKey)
        let savedCollectionURL = try await bookmarkStoreMock.getBookmark(for: TraktorPanelItem.collection.storeKey)
        
        #expect(savedHistoryURL == historyFolder)
        #expect(savedCollectionURL == collectionFile)
        
        // Verify selected version defaults to latest
        guard let updatedData = userDefaultsMock.data(forKey: "traktor.versions") else {
            Issue.record("Versions data not found in UserDefaults")
            return
        }
        
        let decoder = JSONDecoder()
        let updatedVersions = try decoder.decode(TraktorVersions.self, from: updatedData)
        let selectedVersion = updatedVersions.versions.first { $0.isSelected }
        #expect(selectedVersion?.folderName == "Traktor 4.1.1")
    }
}

