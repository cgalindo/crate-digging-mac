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
    
    public init(panel: NSOpenPanel = NSOpenPanel()) {
        self.panel = panel
    }
    
    public func showPanel(for panelItem: PanelItem) async -> URL? {
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
            return nil
        }
        
        return selectedURL
    }
}
