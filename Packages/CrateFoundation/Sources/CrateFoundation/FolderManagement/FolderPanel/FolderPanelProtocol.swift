//
//  FolderPanelProtocol.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

/// Protocol for displaying folder selection panels and saving selected bookmarks.
public protocol FolderPanelProtocol: Sendable {
    
    /// Displays a folder selection panel for the given panel item and saves the selected bookmark.
    /// - Parameter panelItem: The panel item configuration that determines panel behavior
    /// - Throws: An error if the bookmark cannot be saved or if the user cancels the selection
    /// - Note: Implementations should ensure this method runs on the main actor for UI operations
    func showPanel(for panelItem: PanelItem) async throws
}

