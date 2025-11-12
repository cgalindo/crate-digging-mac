//
//  DefaultFileSystemTests.swift
//  CrateDiggingTests
//
//  Created by ChatGPT on 11/11/25.
//

import Testing
@testable import CrateDigging
import Foundation

struct DefaultFileSystemTests {
    private let fileSystem = DefaultFileSystem()
    private let fileManager = FileManager.default
    
    @Test func contentsOfDirectoryReturnsURLs() throws {
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDirectory) }
        
        let fileURL = tempDirectory.appendingPathComponent("test.txt")
        let subDirectoryURL = tempDirectory.appendingPathComponent("Subfolder")
        fileManager.createFile(atPath: fileURL.path, contents: Data("hello".utf8))
        try fileManager.createDirectory(at: subDirectoryURL, withIntermediateDirectories: true)
        
        let contents = try fileSystem.contentsOfDirectory(
            at: tempDirectory,
            includingPropertiesForKeys: nil,
            options: []
        )

        let contentsSet = Set(contents.map { $0.standardizedFileURL })
        let expectedSet = Set([fileURL, subDirectoryURL].map { $0.standardizedFileURL })
        
        #expect(contentsSet == expectedSet)
    }
    
    @Test func fileExistsDetectsFiles() throws {
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDirectory) }
        
        let fileURL = tempDirectory.appendingPathComponent("exists.txt")
        fileManager.createFile(atPath: fileURL.path, contents: Data("crate".utf8))
        
        #expect(fileSystem.fileExists(atPath: fileURL.path))
        #expect(fileSystem.fileExists(atPath: tempDirectory.appendingPathComponent("missing.txt").path) == false)
    }
    
    @Test func isDirectoryDistinguishesDirectories() throws {
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDirectory) }
        
        let directoryURL = tempDirectory.appendingPathComponent("Folder")
        let fileURL = tempDirectory.appendingPathComponent("File.txt")
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        fileManager.createFile(atPath: fileURL.path, contents: Data("crate".utf8))
        
        #expect(fileSystem.isDirectory(atPath: directoryURL.path))
        #expect(fileSystem.isDirectory(atPath: fileURL.path) == false)
    }
}


