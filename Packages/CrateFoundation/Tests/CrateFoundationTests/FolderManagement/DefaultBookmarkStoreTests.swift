//
//  DefaultBookmarkStoreTests.swift
//  CrateFoundationTests
//
//  Created by Chris Galindo on 9/24/25.
//

import Foundation
import Testing
@testable import CrateFoundation

struct DefaultBookmarkStoreTests {
    
    private var bookmarkStore: DefaultBookmarkStore!
    private var tempDirectory: URL!
    
    init() async throws {
        bookmarkStore = DefaultBookmarkStore()
        
        // Create a temporary directory for testing
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("BookmarkStoreTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        tempDirectory = tempDir
    }
    
    // MARK: - Save Bookmark Tests
    
    @Test func saveBookmark() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("test-folder")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "test-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        
        // Then
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == testURL.standardizedFileURL.path)
    }
    
    @Test func saveBookmarkWithMultipleKeys() async throws {
        // Given
        let url1 = tempDirectory.appendingPathComponent("folder1")
        let url2 = tempDirectory.appendingPathComponent("folder2")
        try FileManager.default.createDirectory(at: url1, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: url2, withIntermediateDirectories: true)
        let key1 = "key1"
        let key2 = "key2"
        
        // When
        try await bookmarkStore.saveBookmark(url1, for: key1)
        try await bookmarkStore.saveBookmark(url2, for: key2)
        
        // Then
        let retrievedURL1 = try await bookmarkStore.getBookmark(for: key1)
        let retrievedURL2 = try await bookmarkStore.getBookmark(for: key2)
        
        #expect(retrievedURL1.standardizedFileURL.path == url1.standardizedFileURL.path)
        #expect(retrievedURL2.standardizedFileURL.path == url2.standardizedFileURL.path)
    }
    
    @Test func saveBookmarkOverwritesExisting() async throws {
        // Given
        let originalURL = tempDirectory.appendingPathComponent("original")
        let newURL = tempDirectory.appendingPathComponent("new")
        try FileManager.default.createDirectory(at: originalURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true)
        let key = "overwrite-key"
        
        // When
        try await bookmarkStore.saveBookmark(originalURL, for: key)
        try await bookmarkStore.saveBookmark(newURL, for: key)
        
        // Then
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == newURL.standardizedFileURL.path)
    }
    
    // MARK: - Get Bookmark Tests
    
    @Test func getBookmarkThrowsErrorForNonExistentKey() async {
        // Given
        let nonExistentKey = "non-existent-key"
        
        // When & Then
        await #expect(throws: BookmarkError.bookmarkNotFound(nonExistentKey)) {
            try await bookmarkStore.getBookmark(for: nonExistentKey)
        }
    }
    
    @Test func getBookmarkReturnsCorrectURL() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("retrieve-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "retrieve-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        
        // Then
        #expect(retrievedURL.standardizedFileURL.path == testURL.standardizedFileURL.path)
    }
    
    // MARK: - Security Scope Tests
    
    @Test func bookmarkHasSecurityScope() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("security-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "security-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        
        // Then
        // The URL should be accessible (this is a basic test - in a real scenario,
        // you'd test actual security scope behavior)
        #expect(retrievedURL.startAccessingSecurityScopedResource())
        retrievedURL.stopAccessingSecurityScopedResource()
    }
    
    // MARK: - Concurrent Access Tests
    
    @Test func concurrentSaveAndGet() async throws {
        // Given
        let urls = (0..<10).map { tempDirectory.appendingPathComponent("concurrent-\($0)") }
        let keys = (0..<10).map { "concurrent-key-\($0)" }
        
        // Create directories first
        for url in urls {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        
        // When
        await withTaskGroup(of: Void.self) { group in
            // Save all bookmarks concurrently
            for (url, key) in zip(urls, keys) {
                group.addTask {
                    try? await self.bookmarkStore.saveBookmark(url, for: key)
                }
            }
        }
        
        // Then - retrieve all bookmarks concurrently
        await withTaskGroup(of: (String, URL).self) { group in
            for key in keys {
                group.addTask {
                    let url = try! await self.bookmarkStore.getBookmark(for: key)
                    return (key, url)
                }
            }
            
            var retrievedCount = 0
            for await (key, url) in group {
                let expectedIndex = Int(key.replacingOccurrences(of: "concurrent-key-", with: ""))!
                #expect(url.standardizedFileURL.path == urls[expectedIndex].standardizedFileURL.path)
                retrievedCount += 1
            }
            #expect(retrievedCount == 10)
        }
    }
    
    @Test func concurrentSaveSameKey() async throws {
        // Given
        let key = "concurrent-same-key"
        let urls = (0..<5).map { tempDirectory.appendingPathComponent("same-key-\($0)") }
        
        // Create directories first
        for url in urls {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        
        // When
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    try? await self.bookmarkStore.saveBookmark(url, for: key)
                }
            }
        }
        
        // Then - should be able to retrieve a bookmark (last one wins)
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(urls.contains { $0.standardizedFileURL.path == retrievedURL.standardizedFileURL.path })
    }
    
    // MARK: - Error Handling Tests
    
    @Test func bookmarkErrorDescription() {
        // Given
        let key = "test-key"
        let notFoundError = BookmarkError.bookmarkNotFound(key)
        let emptyKeyError = BookmarkError.emptyKey
        
        // When
        let notFoundDescription = notFoundError.localizedDescription
        let emptyKeyDescription = emptyKeyError.localizedDescription
        
        // Then
        #expect(notFoundDescription == "Bookmark not found for key: \(key)")
        #expect(emptyKeyDescription == "Key cannot be empty")
    }
    
    // MARK: - Edge Cases
    
    @Test func emptyKeyThrowsError() async {
        // Given
        let testURL = tempDirectory.appendingPathComponent("empty-key-test")
        try? FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let emptyKey = ""
        
        // When & Then - saveBookmark should throw emptyKey error
        await #expect(throws: BookmarkError.emptyKey) {
            try await bookmarkStore.saveBookmark(testURL, for: emptyKey)
        }
        
        // When & Then - getBookmark should also throw emptyKey error
        await #expect(throws: BookmarkError.emptyKey) {
            try await bookmarkStore.getBookmark(for: emptyKey)
        }
    }
    
    @Test func specialCharactersInKey() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("special-chars-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let specialKey = "key-with-special-chars!@#$%^&*()"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: specialKey)
        let retrievedURL = try await bookmarkStore.getBookmark(for: specialKey)
        
        // Then
        #expect(retrievedURL.standardizedFileURL.path == testURL.standardizedFileURL.path)
    }
    
    @Test func longKey() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("long-key-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let longKey = String(repeating: "a", count: 1000)
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: longKey)
        let retrievedURL = try await bookmarkStore.getBookmark(for: longKey)
        
        // Then
        #expect(retrievedURL.standardizedFileURL.path == testURL.standardizedFileURL.path)
    }
}
