//
//  SettingsView+ViewModel.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation
import SwiftUI
import CrateFoundation

extension SettingsView {
    
    @Observable
    @MainActor
    final class ViewModel {
        var folderSettings: [FolderSetting] = []
        var errorMessage: String?
        
        private let folderRepository: any FolderRepository
        private let folderPanel: any FolderPanelProtocol
        private let rootFolderUseCase: any RootFolderUseCase
        private let clearAllDataUseCase: any ClearAllDataUseCase
        
        init(
            folderRepository: any FolderRepository = DefaultFolderRepository(),
            folderPanel: any FolderPanelProtocol = FolderPanel(),
            rootFolderUseCase: (any RootFolderUseCase)? = nil,
            clearAllDataUseCase: (any ClearAllDataUseCase)? = nil
        ) {
            self.folderRepository = folderRepository
            self.folderPanel = folderPanel
            self.rootFolderUseCase = rootFolderUseCase ?? TraktorRootFolderUseCase(folderRepository: folderRepository)
            self.clearAllDataUseCase = clearAllDataUseCase ?? DefaultClearAllDataUseCase(
                bookmarkKeys: TraktorPanelItem.allCases.map(\.storeKey),
                userDefaultKeys: [
                    "traktor.versions",
                    "traktor.selectedVersion"
                ]
            )
            initializeFolderSettings()
        }
        
        private func initializeFolderSettings() {
            folderSettings = [
                FolderSetting(title: "Root Folder", panelItem: .rootFolder),
                FolderSetting(title: "History Folder", panelItem: .historyFolder),
                FolderSetting(title: "Collection", panelItem: .collection)
            ]
        }
        
        func loadData() async {
            await loadFolderPaths()
        }
        
        private func loadFolderPaths() async {
            var updatedSettings = folderSettings
            for (index, setting) in updatedSettings.enumerated() {
                do {
                    let urlString = try await folderRepository.fetchBookmark(for: setting.panelItem.storeKey)
                    guard let url = URL(string: urlString),
                          url.scheme != nil
                    else {
                        updatedSettings[index].path = nil
                        continue
                    }
                    updatedSettings[index].path = url.path
                } catch {
                    // Folder path not set yet, path remains nil
                    updatedSettings[index].path = nil
                }
            }
            // Assign the updated array to trigger SwiftUI updates
            folderSettings = updatedSettings
        }
        
        func changeFolder(for setting: FolderSetting) async {
            // Show panel and get selected URL
            guard let selectedURL = await folderPanel.showPanel(for: setting.panelItem) else {
                // User cancelled - no action needed
                return
            }
            
            // Save the bookmark
            let bookmark = Bookmark(url: selectedURL, key: setting.panelItem.storeKey)
            do {
                try await folderRepository.save(bookmark)
            } catch {
                // Set error message for display
                errorMessage = error.localizedDescription
                
                // Error saving bookmark - reload to ensure UI is in sync
                await loadFolderPaths()
                return
            }
            
            // If root folder was selected, process it to bookmark history and collection
            if isRootFolder(setting) {
                // Process root folder to find versions and bookmark history/collection
                do {
                    try await rootFolderUseCase(selectedURL)
                } catch let error as TraktorRootFolderError {
                    // Clear the root folder bookmark since validation failed
                    try? await folderRepository.removeBookmark(for: TraktorPanelItem.rootFolder.storeKey)
                    
                    // Set error message for display
                    errorMessage = error.localizedDescription
                    
                    // Reload paths to reflect cleared state
                    await loadFolderPaths()
                    return
                } catch {
                    // Other errors from rootFolderUseCase - clear bookmark and reload
                    try? await folderRepository.removeBookmark(for: TraktorPanelItem.rootFolder.storeKey)
                    await loadFolderPaths()
                    return
                }
            }
            
            // Reload all paths after saving
            await loadFolderPaths()
        }
        
        func isRootFolder(_ setting: FolderSetting) -> Bool {
            setting.panelItem == .rootFolder
        }
        
        func displayText(for setting: FolderSetting) -> String {
            setting.path ?? "No folder selected"
        }
        
        func foregroundColor(for setting: FolderSetting) -> Color {
            setting.path != nil ? .primary : .secondary
        }
        
        func clearAllData() async {
            clearAllDataUseCase()
            
            // Reload folder paths to reflect cleared state
            await loadFolderPaths()
        }
        
        func clearErrorMessage() {
            errorMessage = nil
        }
    }
    
}

