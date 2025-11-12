//
//  RootFolderUseCaseMock.swift
//  CrateDiggingTests
//
//  Created by Chris Galindo on 11/11/25.
//

import Foundation
@testable import CrateDigging

actor RootFolderUseCaseMock: RootFolderUseCase {
    private let handler: (@Sendable (URL) async throws -> Void)?
    private var urls: [URL] = []
    
    init(handler: (@Sendable (URL) async throws -> Void)? = nil) {
        self.handler = handler
    }
    
    func callAsFunction(_ rootFolderURL: URL) async throws {
        urls.append(rootFolderURL)
        try await handler?(rootFolderURL)
    }
    
    func receivedURLs() -> [URL] {
        urls
    }
}
