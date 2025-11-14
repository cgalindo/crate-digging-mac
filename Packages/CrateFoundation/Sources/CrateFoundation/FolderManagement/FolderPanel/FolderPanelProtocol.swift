//
//  FolderPanelProtocol.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

/// Protocol for displaying folder selection panels.
public protocol FolderPanelProtocol: Sendable {
    
    /// Displays a folder selection panel for the given panel item and returns the selected URL.
    /// - Parameter panelItem: The panel item configuration that determines panel behavior
    /// - Returns: The selected URL, or `nil` if the user cancelled the selection
    /// - Note: Implementations should ensure this method runs on the main actor for UI operations
    func showPanel(for panelItem: PanelItem) async -> URL?
}

