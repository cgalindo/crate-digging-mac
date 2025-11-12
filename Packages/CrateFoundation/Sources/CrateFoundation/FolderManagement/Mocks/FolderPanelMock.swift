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
    private let handler: (@Sendable (PanelItem) async throws -> Void)?
    private var calls: [String] = []
    
    init(handler: (@Sendable (PanelItem) async throws -> Void)? = nil) {
        self.handler = handler
    }
    
    func showPanel(for panelItem: PanelItem) async throws {
        calls.append(panelItem.storeKey)
        try await handler?(panelItem)
    }
    
    func shownStoreKeys() -> [String] {
        calls
    }
}

