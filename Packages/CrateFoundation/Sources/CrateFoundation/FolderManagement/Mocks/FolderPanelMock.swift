//
//  FolderPanelMock.swift
//  CrateFoundationTests
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

/// Black box mock implementation of FolderPanelProtocol for testing
@MainActor
final class FolderPanelMock: FolderPanelProtocol {
    private let handler: (@Sendable (PanelItem) async -> URL?)?
    private var calls: [String] = []
    
    init(handler: (@Sendable (PanelItem) async -> URL?)? = nil) {
        self.handler = handler
    }
    
    func showPanel(for panelItem: PanelItem) async -> URL? {
        calls.append(panelItem.storeKey)
        return await handler?(panelItem)
    }
    
    func shownStoreKeys() -> [String] {
        calls
    }
}

