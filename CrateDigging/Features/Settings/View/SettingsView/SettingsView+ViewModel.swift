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
        
        private let folderRepository: any FolderRepository
        private let folderPanel: any FolderPanelProtocol
        private let rootFolderUseCase: any RootFolderUseCase
        private let clearAllDataUseCase: any ClearAllDataUseCase
        
        init(
            folderRepository: any FolderRepository = DefaultFolderRepository(),
            folderPanel: (any FolderPanelProtocol)? = nil,
            rootFolderUseCase: (any RootFolderUseCase)? = nil,
            clearAllDataUseCase: (any ClearAllDataUseCase)? = nil
        ) {
            self.folderRepository = folderRepository
            self.folderPanel = folderPanel ?? FolderPanel(repository: folderRepository)
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
                    guard let url = URL(string: urlString) else {
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
            do {
                try await folderPanel.showPanel(for: setting.panelItem)
                
                // If root folder was selected, process it to bookmark history and collection
                if isRootFolder(setting) {
                    // Get the root folder URL that was just saved
                    let rootFolderString = try await folderRepository.fetchBookmark(for: TraktorPanelItem.rootFolder.storeKey)
                    guard let rootFolderURL = URL(string: rootFolderString) else {
                        await loadFolderPaths()
                        return
                    }
                    
                    // Process root folder to find versions and bookmark history/collection
                    try await rootFolderUseCase(rootFolderURL)
                }
                
                // Reload all paths after saving
                await loadFolderPaths()
            } catch {
                // User cancelled or error occurred - still reload to ensure UI is in sync
                await loadFolderPaths()
            }
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
    }
    
}

