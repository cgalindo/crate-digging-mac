//
//  FileSystem.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

/// Protocol for file system operations, allowing for dependency injection and testing
protocol FileSystem: Sendable {
    /// Returns the contents of the directory at the specified URL
    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL]
    
    /// Returns a Boolean value that indicates whether a file or directory exists at a specified path
    func fileExists(atPath path: String) -> Bool
    
    /// Returns a Boolean value that indicates whether the path is a directory
    func isDirectory(atPath path: String) -> Bool
}

