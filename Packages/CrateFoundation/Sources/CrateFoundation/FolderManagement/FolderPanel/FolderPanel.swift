//
//  FolderPanel.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 10/21/25.
//

import Foundation
import AppKit

@MainActor
final public class FolderPanel: FolderPanelProtocol {
    let panel: NSOpenPanel
    let repository: any FolderRepository
    
    public init(
        panel: NSOpenPanel = NSOpenPanel(),
        repository: any FolderRepository
    ) {
        self.panel = panel
        self.repository = repository
    }
    
    public func showPanel(for panelItem: PanelItem) async throws {
        panel.title = panelItem.title
        panel.message = panelItem.message
        panel.prompt = panelItem.prompt
        panel.canChooseDirectories = panelItem.canChooseDirectories
        panel.canChooseFiles = panelItem.canChooseFiles
        panel.allowsMultipleSelection = panelItem.allowsMultipleSelection
        panel.canCreateDirectories = panelItem.cancreateDirectories
        
        if let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first {
            panel.directoryURL = documentsURL
        }
        
        let response = panel.runModal()
        
        guard response == .OK, let selectedURL = panel.url else {
            return
        }
        
        // Create bookmark and save through repository
        // The repository will handle synchronous bookmark creation for files
        // to maintain NSOpenPanel access, while keeping separation of concerns
        let bookmark = Bookmark(
            url: selectedURL,
            key: panelItem.storeKey
        )
        try await repository.save(bookmark)
    }
}
