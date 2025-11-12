//
//  DefaultFileSystemMock.swift
//  CrateDiggingTests
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation
@testable import CrateDigging

/// Black box mock implementation of FileSystem for testing
final class DefaultFileSystemMock: FileSystem {
    // MARK: - Expected Return Values
    
    let expectedContentsOfDirectoryResult: [URL]
    let expectedContentsOfDirectoryError: Error?
    
    private let fileExistsHandler: @Sendable (String) -> Bool
    private let isDirectoryHandler: @Sendable (String) -> Bool
    
    // MARK: - FileSystem Implementation
    
    init(
        expectedContentsOfDirectoryResult: [URL] = [],
        expectedContentsOfDirectoryError: Error? = nil,
        fileExistsHandler: @escaping @Sendable (String) -> Bool = { _ in false },
        isDirectoryHandler: @escaping @Sendable (String) -> Bool = { _ in true }
    ) {
        self.expectedContentsOfDirectoryResult = expectedContentsOfDirectoryResult
        self.expectedContentsOfDirectoryError = expectedContentsOfDirectoryError
        self.fileExistsHandler = fileExistsHandler
        self.isDirectoryHandler = isDirectoryHandler
    }
    
    convenience init(
        expectedContentsOfDirectoryResult: [URL] = [],
        expectedContentsOfDirectoryError: Error? = nil,
        expectedFileExistsResult: Bool = false,
        expectedIsDirectoryResult: Bool = true
    ) {
        self.init(
            expectedContentsOfDirectoryResult: expectedContentsOfDirectoryResult,
            expectedContentsOfDirectoryError: expectedContentsOfDirectoryError,
            fileExistsHandler: { _ in expectedFileExistsResult },
            isDirectoryHandler: { _ in expectedIsDirectoryResult }
        )
    }
    
    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL] {
        if let error = expectedContentsOfDirectoryError {
            throw error
        }
        
        return expectedContentsOfDirectoryResult
    }
    
    func fileExists(atPath path: String) -> Bool {
        return fileExistsHandler(path)
    }
    
    func isDirectory(atPath path: String) -> Bool {
        return isDirectoryHandler(path)
    }
}

