//
//  SettingsViewViewModelTests.swift
//  CrateDiggingTests
//
//  Created by ChatGPT on 11/11/25.
//

import Testing
@testable import CrateDigging
@testable import CrateFoundation
import Foundation
import SwiftUI

@MainActor
struct SettingsViewViewModelTests {
    
    // MARK: - Initialization
    
    @Test func initializesDefaultFolderSettings() async throws {
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        #expect(viewModel.folderSettings.count == 3)
        #expect(viewModel.folderSettings.contains(where: { $0.panelItem == .rootFolder }))
        #expect(viewModel.folderSettings.contains(where: { $0.panelItem == .historyFolder }))
        #expect(viewModel.folderSettings.contains(where: { $0.panelItem == .collection }))
    }
    
    // MARK: - Data Loading
    
    @Test func loadDataPopulatesFolderPaths() async throws {
        let repository = FolderRepositoryMock()
        
        await repository.setBookmark(
            URL(fileURLWithPath: "/root").absoluteString,
            for: TraktorPanelItem.rootFolder.storeKey
        )
        await repository.setBookmark(
            URL(fileURLWithPath: "/history").absoluteString,
            for: TraktorPanelItem.historyFolder.storeKey
        )
        await repository.setBookmark(
            URL(fileURLWithPath: "/collection.nml").absoluteString,
            for: TraktorPanelItem.collection.storeKey
        )
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        await viewModel.loadData()
        
        let pathsByKey = Dictionary(
            uniqueKeysWithValues: viewModel.folderSettings.map { ($0.panelItem.storeKey, $0.path) }
        )
        
        #expect(pathsByKey[TraktorPanelItem.rootFolder.storeKey] == "/root")
        #expect(pathsByKey[TraktorPanelItem.historyFolder.storeKey] == "/history")
        #expect(pathsByKey[TraktorPanelItem.collection.storeKey] == "/collection.nml")
    }
    
    // MARK: - Folder Changes
    
    @Test func changeFolderProcessesRootFolderSelection() async throws {
        let repository = FolderRepositoryMock()
        
        let rootURL = URL(fileURLWithPath: "/Native Instruments")
        let historyURL = rootURL.appendingPathComponent("Traktor 4.1.1").appendingPathComponent("History")
        let collectionURL = rootURL.appendingPathComponent("Traktor 4.1.1").appendingPathComponent("collection.nml")
        
        let folderPanel = FolderPanelMock { panelItem in
            #expect(panelItem.storeKey == TraktorPanelItem.rootFolder.storeKey)
            return rootURL
        }
        
        let rootUseCase = RootFolderUseCaseMock { url in
            #expect(url == rootURL)
            await repository.setBookmark(historyURL.absoluteString, for: TraktorPanelItem.historyFolder.storeKey)
            await repository.setBookmark(collectionURL.absoluteString, for: TraktorPanelItem.collection.storeKey)
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: rootUseCase
        )
        
        guard let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder }) else {
            Issue.record("Root setting not initialized")
            return
        }
        
        await viewModel.changeFolder(for: rootSetting)
        
        let pathsByItem = Dictionary(uniqueKeysWithValues: viewModel.folderSettings.map { ($0.panelItem, $0.path ?? "") })
        
        #expect(pathsByItem[.rootFolder] == rootURL.path)
        #expect(pathsByItem[.historyFolder] == historyURL.path)
        #expect(pathsByItem[.collection] == collectionURL.path)
        
        #expect(await folderPanel.shownStoreKeys() == [TraktorPanelItem.rootFolder.storeKey])
        #expect(await rootUseCase.receivedURLs() == [rootURL])
    }
    
    // MARK: - Clear All Data
    
    @Test func clearAllDataCallsUseCase() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let clearAllDataUseCaseMock = ClearAllDataUseCaseMock()
        
        // Pre-populate with bookmarks
        await repository.setBookmark(
            URL(fileURLWithPath: "/root").absoluteString,
            for: TraktorPanelItem.rootFolder.storeKey
        )
        await repository.setBookmark(
            URL(fileURLWithPath: "/history").absoluteString,
            for: TraktorPanelItem.historyFolder.storeKey
        )
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock(),
            clearAllDataUseCase: clearAllDataUseCaseMock
        )
        
        // Load data to populate paths
        await viewModel.loadData()
        
        // Verify paths are populated
        let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder })
        #expect(rootSetting?.path != nil)
        
        // When
        await viewModel.clearAllData()
        
        // Then - use case should be called
        #expect(clearAllDataUseCaseMock.getCallCount() == 1)
    }
    
    @Test func clearAllDataReloadsFolderPaths() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let clearAllDataUseCaseMock = ClearAllDataUseCaseMock()
        
        // Pre-populate with bookmarks
        await repository.setBookmark(
            URL(fileURLWithPath: "/root").absoluteString,
            for: TraktorPanelItem.rootFolder.storeKey
        )
        await repository.setBookmark(
            URL(fileURLWithPath: "/history").absoluteString,
            for: TraktorPanelItem.historyFolder.storeKey
        )
        await repository.setBookmark(
            URL(fileURLWithPath: "/collection.nml").absoluteString,
            for: TraktorPanelItem.collection.storeKey
        )
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock(),
            clearAllDataUseCase: clearAllDataUseCaseMock
        )
        
        // Load data to populate paths
        await viewModel.loadData()
        
        // Verify paths are populated
        let pathsBefore = viewModel.folderSettings.map { $0.path }
        #expect(pathsBefore.allSatisfy { $0 != nil })
        
        // Clear bookmarks from repository (simulating what clearAllDataUseCase does)
        // This simulates the use case clearing UserDefaults, which would make fetchBookmark fail
        await repository.setBookmark("", for: TraktorPanelItem.rootFolder.storeKey)
        await repository.setBookmark("", for: TraktorPanelItem.historyFolder.storeKey)
        await repository.setBookmark("", for: TraktorPanelItem.collection.storeKey)
        
        // When
        await viewModel.clearAllData()
        
        // Then - use case should be called
        #expect(clearAllDataUseCaseMock.getCallCount() == 1)
        
        // Paths should be reloaded and set to nil since bookmarks return empty strings (which become nil URLs)
        let pathsAfter = viewModel.folderSettings.map { $0.path }
        #expect(pathsAfter.allSatisfy { $0 == nil })
    }
    
    @Test func clearAllDataHandlesEmptyPaths() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let clearAllDataUseCaseMock = ClearAllDataUseCaseMock()
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock(),
            clearAllDataUseCase: clearAllDataUseCaseMock
        )
        
        // Load data (no bookmarks exist, so paths will be nil)
        await viewModel.loadData()
        
        // Verify paths are nil
        let pathsBefore = viewModel.folderSettings.map { $0.path }
        #expect(pathsBefore.allSatisfy { $0 == nil })
        
        // When
        await viewModel.clearAllData()
        
        // Then - paths should still be nil
        let pathsAfter = viewModel.folderSettings.map { $0.path }
        #expect(pathsAfter.allSatisfy { $0 == nil })
        #expect(clearAllDataUseCaseMock.getCallCount() == 1)
    }
    
    @Test func clearAllDataCallsUseCaseAndReloadsEvenWhenSomeBookmarksExist() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let clearAllDataUseCaseMock = ClearAllDataUseCaseMock()
        
        // Only set one bookmark
        await repository.setBookmark(
            URL(fileURLWithPath: "/root").absoluteString,
            for: TraktorPanelItem.rootFolder.storeKey
        )
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock(),
            clearAllDataUseCase: clearAllDataUseCaseMock
        )
        
        // Load data
        await viewModel.loadData()
        
        // Verify one path is populated
        let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder })
        #expect(rootSetting?.path == "/root")
        
        // Clear the bookmark (simulating what clearAllDataUseCase does)
        await repository.setBookmark("", for: TraktorPanelItem.rootFolder.storeKey)
        
        // When
        await viewModel.clearAllData()
        
        // Then - use case should be called and paths should be reloaded
        #expect(clearAllDataUseCaseMock.getCallCount() == 1)
        
        // All paths should be nil after reload
        let pathsAfter = viewModel.folderSettings.map { $0.path }
        #expect(pathsAfter.allSatisfy { $0 == nil })
    }
    
    // MARK: - Display Text
    
    @Test func displayTextReturnsPathWhenPathExists() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let setting = FolderSetting(
            title: "Test Folder",
            path: "/path/to/folder",
            panelItem: .rootFolder
        )
        
        // When
        let displayText = viewModel.displayText(for: setting)
        
        // Then
        #expect(displayText == "/path/to/folder")
    }
    
    @Test func displayTextReturnsNoFolderSelectedWhenPathIsNil() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let setting = FolderSetting(
            title: "Test Folder",
            path: nil,
            panelItem: .rootFolder
        )
        
        // When
        let displayText = viewModel.displayText(for: setting)
        
        // Then
        #expect(displayText == "No folder selected")
    }
    
    @Test func displayTextReturnsPathForDifferentFolderSettings() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let rootSetting = FolderSetting(
            title: "Root Folder",
            path: "/root/path",
            panelItem: .rootFolder
        )
        
        let historySetting = FolderSetting(
            title: "History Folder",
            path: "/history/path",
            panelItem: .historyFolder
        )
        
        let collectionSetting = FolderSetting(
            title: "Collection",
            path: "/collection.nml",
            panelItem: .collection
        )
        
        // When
        let rootDisplayText = viewModel.displayText(for: rootSetting)
        let historyDisplayText = viewModel.displayText(for: historySetting)
        let collectionDisplayText = viewModel.displayText(for: collectionSetting)
        
        // Then
        #expect(rootDisplayText == "/root/path")
        #expect(historyDisplayText == "/history/path")
        #expect(collectionDisplayText == "/collection.nml")
    }
    
    @Test func displayTextReturnsNoFolderSelectedForAllSettingsWhenPathsAreNil() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let rootSetting = FolderSetting(
            title: "Root Folder",
            path: nil,
            panelItem: .rootFolder
        )
        
        let historySetting = FolderSetting(
            title: "History Folder",
            path: nil,
            panelItem: .historyFolder
        )
        
        let collectionSetting = FolderSetting(
            title: "Collection",
            path: nil,
            panelItem: .collection
        )
        
        // When
        let rootDisplayText = viewModel.displayText(for: rootSetting)
        let historyDisplayText = viewModel.displayText(for: historySetting)
        let collectionDisplayText = viewModel.displayText(for: collectionSetting)
        
        // Then
        #expect(rootDisplayText == "No folder selected")
        #expect(historyDisplayText == "No folder selected")
        #expect(collectionDisplayText == "No folder selected")
    }
    
    @Test func displayTextHandlesEmptyStringPath() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let setting = FolderSetting(
            title: "Test Folder",
            path: "",
            panelItem: .rootFolder
        )
        
        // When
        let displayText = viewModel.displayText(for: setting)
        
        // Then - empty string is not nil, so it should return the empty string
        #expect(displayText == "")
    }
    
    // MARK: - Foreground Color
    
    @Test func foregroundColorReturnsPrimaryWhenPathExists() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let setting = FolderSetting(
            title: "Test Folder",
            path: "/path/to/folder",
            panelItem: .rootFolder
        )
        
        // When
        let color = viewModel.foregroundColor(for: setting)
        
        // Then
        #expect(color == .primary)
    }
    
    @Test func foregroundColorReturnsSecondaryWhenPathIsNil() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let setting = FolderSetting(
            title: "Test Folder",
            path: nil,
            panelItem: .rootFolder
        )
        
        // When
        let color = viewModel.foregroundColor(for: setting)
        
        // Then
        #expect(color == .secondary)
    }
    
    @Test func foregroundColorReturnsPrimaryForDifferentFolderSettingsWithPaths() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let rootSetting = FolderSetting(
            title: "Root Folder",
            path: "/root/path",
            panelItem: .rootFolder
        )
        
        let historySetting = FolderSetting(
            title: "History Folder",
            path: "/history/path",
            panelItem: .historyFolder
        )
        
        let collectionSetting = FolderSetting(
            title: "Collection",
            path: "/collection.nml",
            panelItem: .collection
        )
        
        // When
        let rootColor = viewModel.foregroundColor(for: rootSetting)
        let historyColor = viewModel.foregroundColor(for: historySetting)
        let collectionColor = viewModel.foregroundColor(for: collectionSetting)
        
        // Then
        #expect(rootColor == .primary)
        #expect(historyColor == .primary)
        #expect(collectionColor == .primary)
    }
    
    @Test func foregroundColorReturnsSecondaryForAllSettingsWhenPathsAreNil() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let rootSetting = FolderSetting(
            title: "Root Folder",
            path: nil,
            panelItem: .rootFolder
        )
        
        let historySetting = FolderSetting(
            title: "History Folder",
            path: nil,
            panelItem: .historyFolder
        )
        
        let collectionSetting = FolderSetting(
            title: "Collection",
            path: nil,
            panelItem: .collection
        )
        
        // When
        let rootColor = viewModel.foregroundColor(for: rootSetting)
        let historyColor = viewModel.foregroundColor(for: historySetting)
        let collectionColor = viewModel.foregroundColor(for: collectionSetting)
        
        // Then
        #expect(rootColor == .secondary)
        #expect(historyColor == .secondary)
        #expect(collectionColor == .secondary)
    }
    
    @Test func foregroundColorReturnsPrimaryForEmptyStringPath() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let setting = FolderSetting(
            title: "Test Folder",
            path: "",
            panelItem: .rootFolder
        )
        
        // When
        let color = viewModel.foregroundColor(for: setting)
        
        // Then - empty string is not nil, so it should return primary
        #expect(color == .primary)
    }
    
    // MARK: - Error Handling
    
    @Test func changeFolderHandlesUserCancellation() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let folderPanel = FolderPanelMock { _ in
            return nil // User cancelled
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        guard let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder }) else {
            Issue.record("Root setting not initialized")
            return
        }
        
        // When
        await viewModel.changeFolder(for: rootSetting)
        
        // Then - No bookmarks should be saved
        #expect(await repository.getStoredBookmarkCount() == 0)
    }
    
    @Test func changeFolderHandlesBookmarkSaveError() async throws {
        // Given
        let repository = FolderRepositoryMock()
        await repository.setShouldThrowError(true, error: BookmarkError.emptyKey)
        
        let selectedURL = URL(fileURLWithPath: "/test/folder")
        let folderPanel = FolderPanelMock { _ in
            return selectedURL
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        guard let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder }) else {
            Issue.record("Root setting not initialized")
            return
        }
        
        // When
        await viewModel.changeFolder(for: rootSetting)
        
        // Then - Error message should be set
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("empty") == true || viewModel.errorMessage?.contains("key") == true)
    }
    
    @Test func changeFolderHandlesTraktorRootFolderErrorNoVersionsFound() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let selectedURL = URL(fileURLWithPath: "/test/folder")
        
        let folderPanel = FolderPanelMock { _ in
            return selectedURL
        }
        
        let rootUseCase = RootFolderUseCaseMock { _ in
            throw TraktorRootFolderError.noTraktorVersionsFound
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: rootUseCase
        )
        
        guard let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder }) else {
            Issue.record("Root setting not initialized")
            return
        }
        
        // When
        await viewModel.changeFolder(for: rootSetting)
        
        // Then - Root folder bookmark should be cleared
        #expect(await repository.hasBookmark(for: TraktorPanelItem.rootFolder.storeKey) == false)
        
        // Error message should be set
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("No Traktor version folders") == true)
        
        // Root folder path should be cleared
        let rootPath = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder })?.path
        #expect(rootPath == nil)
    }
    
    @Test func changeFolderHandlesTraktorRootFolderErrorHistoryNotFound() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let selectedURL = URL(fileURLWithPath: "/test/folder")
        
        let folderPanel = FolderPanelMock { _ in
            return selectedURL
        }
        
        let rootUseCase = RootFolderUseCaseMock { _ in
            throw TraktorRootFolderError.historyFolderNotFound
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: rootUseCase
        )
        
        guard let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder }) else {
            Issue.record("Root setting not initialized")
            return
        }
        
        // When
        await viewModel.changeFolder(for: rootSetting)
        
        // Then - Root folder bookmark should be cleared
        #expect(await repository.hasBookmark(for: TraktorPanelItem.rootFolder.storeKey) == false)
        
        // Error message should be set
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("History folder not found") == true)
    }
    
    @Test func changeFolderHandlesTraktorRootFolderErrorCollectionNotFound() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let selectedURL = URL(fileURLWithPath: "/test/folder")
        
        let folderPanel = FolderPanelMock { _ in
            return selectedURL
        }
        
        let rootUseCase = RootFolderUseCaseMock { _ in
            throw TraktorRootFolderError.collectionFileNotFound
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: rootUseCase
        )
        
        guard let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder }) else {
            Issue.record("Root setting not initialized")
            return
        }
        
        // When
        await viewModel.changeFolder(for: rootSetting)
        
        // Then - Root folder bookmark should be cleared
        #expect(await repository.hasBookmark(for: TraktorPanelItem.rootFolder.storeKey) == false)
        
        // Error message should be set
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("Collection file") == true)
    }
    
    @Test func changeFolderHandlesOtherRootFolderUseCaseErrors() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let selectedURL = URL(fileURLWithPath: "/test/folder")
        let testError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        let folderPanel = FolderPanelMock { _ in
            return selectedURL
        }
        
        let rootUseCase = RootFolderUseCaseMock { _ in
            throw testError
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: rootUseCase
        )
        
        guard let rootSetting = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder }) else {
            Issue.record("Root setting not initialized")
            return
        }
        
        // When
        await viewModel.changeFolder(for: rootSetting)
        
        // Then - Root folder bookmark should be cleared
        #expect(await repository.hasBookmark(for: TraktorPanelItem.rootFolder.storeKey) == false)
    }
    
    @Test func changeFolderHandlesNonRootFolderSelection() async throws {
        // Given
        let repository = FolderRepositoryMock()
        let selectedURL = URL(fileURLWithPath: "/test/history")
        
        let folderPanel = FolderPanelMock { _ in
            return selectedURL
        }
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: folderPanel,
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        guard let historySetting = viewModel.folderSettings.first(where: { $0.panelItem == .historyFolder }) else {
            Issue.record("History setting not initialized")
            return
        }
        
        // When
        await viewModel.changeFolder(for: historySetting)
        
        // Then - History bookmark should be saved
        #expect(await repository.hasBookmark(for: TraktorPanelItem.historyFolder.storeKey) == true)
        
        // Root folder use case should not be called
        #expect(await folderPanel.shownStoreKeys() == [TraktorPanelItem.historyFolder.storeKey])
    }
    
    @Test func loadFolderPathsHandlesInvalidURLString() async throws {
        // Given
        let repository = FolderRepositoryMock()
        // Set an invalid URL string (not a valid URL)
        await repository.setBookmark("not a valid url", for: TraktorPanelItem.rootFolder.storeKey)
        
        let viewModel = SettingsView.ViewModel(
            folderRepository: repository,
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        // When
        await viewModel.loadData()
        
        // Then - Path should be nil for invalid URL
        let rootPath = viewModel.folderSettings.first(where: { $0.panelItem == .rootFolder })?.path
        #expect(rootPath == nil)
    }
    
    @Test func clearErrorMessageClearsError() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        viewModel.errorMessage = "Test error"
        #expect(viewModel.errorMessage != nil)
        
        // When
        viewModel.clearErrorMessage()
        
        // Then
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func isRootFolderReturnsTrueForRootFolder() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let rootSetting = FolderSetting(
            title: "Root Folder",
            path: nil,
            panelItem: .rootFolder
        )
        
        // When
        let isRoot = viewModel.isRootFolder(rootSetting)
        
        // Then
        #expect(isRoot == true)
    }
    
    @Test func isRootFolderReturnsFalseForNonRootFolder() {
        // Given
        let viewModel = SettingsView.ViewModel(
            folderRepository: FolderRepositoryMock(),
            folderPanel: FolderPanelMock(),
            rootFolderUseCase: RootFolderUseCaseMock()
        )
        
        let historySetting = FolderSetting(
            title: "History Folder",
            path: nil,
            panelItem: .historyFolder
        )
        
        // When
        let isRoot = viewModel.isRootFolder(historySetting)
        
        // Then
        #expect(isRoot == false)
    }
}
