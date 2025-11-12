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
    
    // MARK: - Remove Bookmark Tests
    
    @Test func removeBookmark() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("remove-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "remove-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        try await bookmarkStore.removeBookmark(for: key)
        
        // Then - bookmark should no longer exist
        await #expect(throws: BookmarkError.bookmarkNotFound(key)) {
            try await bookmarkStore.getBookmark(for: key)
        }
    }
    
    @Test func removeBookmarkThrowsErrorForNonExistentKey() async {
        // Given
        let nonExistentKey = "non-existent-remove-key"
        
        // When & Then
        await #expect(throws: BookmarkError.bookmarkNotFound(nonExistentKey)) {
            try await bookmarkStore.removeBookmark(for: nonExistentKey)
        }
    }
    
    @Test func removeBookmarkThrowsErrorForEmptyKey() async {
        // Given
        let emptyKey = ""
        
        // When & Then
        await #expect(throws: BookmarkError.emptyKey) {
            try await bookmarkStore.removeBookmark(for: emptyKey)
        }
    }
    
    @Test func removeBookmarkRemovesFromUserDefaults() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("userdefaults-remove-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "userdefaults-remove-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        // Verify it's in UserDefaults
        let dataBefore = UserDefaults.standard.data(forKey: key)
        #expect(dataBefore != nil)
        
        try await bookmarkStore.removeBookmark(for: key)
        
        // Then - should be removed from UserDefaults
        let dataAfter = UserDefaults.standard.data(forKey: key)
        #expect(dataAfter == nil)
    }
    
    @Test func removeBookmarkForFile() async throws {
        // Given
        let testFile = tempDirectory.appendingPathComponent("remove-file.txt")
        try "test content".write(to: testFile, atomically: true, encoding: .utf8)
        let key = "remove-file-key"
        
        // When
        try await bookmarkStore.saveBookmark(testFile, for: key)
        try await bookmarkStore.removeBookmark(for: key)
        
        // Then - bookmark should no longer exist
        await #expect(throws: BookmarkError.bookmarkNotFound(key)) {
            try await bookmarkStore.getBookmark(for: key)
        }
    }
    
    @Test func removeBookmarkDoesNotAffectOtherBookmarks() async throws {
        // Given
        let url1 = tempDirectory.appendingPathComponent("remove-isolated-1")
        let url2 = tempDirectory.appendingPathComponent("remove-isolated-2")
        try FileManager.default.createDirectory(at: url1, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: url2, withIntermediateDirectories: true)
        let key1 = "isolated-key-1"
        let key2 = "isolated-key-2"
        
        // When
        try await bookmarkStore.saveBookmark(url1, for: key1)
        try await bookmarkStore.saveBookmark(url2, for: key2)
        try await bookmarkStore.removeBookmark(for: key1)
        
        // Then - key2 should still exist
        let retrievedURL2 = try await bookmarkStore.getBookmark(for: key2)
        #expect(retrievedURL2.standardizedFileURL.path == url2.standardizedFileURL.path)
        
        // And key1 should be gone
        await #expect(throws: BookmarkError.bookmarkNotFound(key1)) {
            try await bookmarkStore.getBookmark(for: key1)
        }
    }
    
    @Test func removeMultipleBookmarks() async throws {
        // Given
        let urls = (0..<5).map { tempDirectory.appendingPathComponent("remove-multiple-\($0)") }
        let keys = (0..<5).map { "remove-multiple-key-\($0)" }
        
        // Create directories and save bookmarks
        for url in urls {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        for (url, key) in zip(urls, keys) {
            try await bookmarkStore.saveBookmark(url, for: key)
        }
        
        // When - remove all bookmarks
        for key in keys {
            try await bookmarkStore.removeBookmark(for: key)
        }
        
        // Then - all bookmarks should be removed
        for key in keys {
            await #expect(throws: BookmarkError.bookmarkNotFound(key)) {
                try await bookmarkStore.getBookmark(for: key)
            }
        }
    }
    
    @Test func removeAndReAddBookmark() async throws {
        // Given
        let originalURL = tempDirectory.appendingPathComponent("remove-readd-original")
        let newURL = tempDirectory.appendingPathComponent("remove-readd-new")
        try FileManager.default.createDirectory(at: originalURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true)
        let key = "remove-readd-key"
        
        // When
        try await bookmarkStore.saveBookmark(originalURL, for: key)
        try await bookmarkStore.removeBookmark(for: key)
        try await bookmarkStore.saveBookmark(newURL, for: key)
        
        // Then - should retrieve the new bookmark
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == newURL.standardizedFileURL.path)
    }
    
    @Test func concurrentRemoveBookmarks() async throws {
        // Given
        let urls = (0..<10).map { tempDirectory.appendingPathComponent("concurrent-remove-\($0)") }
        let keys = (0..<10).map { "concurrent-remove-key-\($0)" }
        
        // Create directories and save bookmarks
        for url in urls {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        for (url, key) in zip(urls, keys) {
            try await bookmarkStore.saveBookmark(url, for: key)
        }
        
        // When - remove all bookmarks concurrently
        await withTaskGroup(of: Void.self) { group in
            for key in keys {
                group.addTask {
                    try? await self.bookmarkStore.removeBookmark(for: key)
                }
            }
        }
        
        // Then - all bookmarks should be removed
        for key in keys {
            await #expect(throws: BookmarkError.bookmarkNotFound(key)) {
                try await bookmarkStore.getBookmark(for: key)
            }
        }
    }
    
    @Test func removeBookmarkWithSpecialCharactersInKey() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("remove-special-chars-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let specialKey = "remove-key-with-special-chars!@#$%^&*()"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: specialKey)
        try await bookmarkStore.removeBookmark(for: specialKey)
        
        // Then
        await #expect(throws: BookmarkError.bookmarkNotFound(specialKey)) {
            try await bookmarkStore.getBookmark(for: specialKey)
        }
    }
    
    @Test func removeBookmarkWithLongKey() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("remove-long-key-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        // Use a unique long key to avoid conflicts with other tests
        let longKey = "remove-" + String(repeating: "a", count: 1000)
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: longKey)
        // Verify it's in UserDefaults
        let dataBefore = UserDefaults.standard.data(forKey: longKey)
        #expect(dataBefore != nil)
        
        try await bookmarkStore.removeBookmark(for: longKey)
        
        // Verify it's removed from UserDefaults
        let dataAfter = UserDefaults.standard.data(forKey: longKey)
        #expect(dataAfter == nil)
        
        // Then - should throw error when trying to get removed bookmark
        await #expect(throws: BookmarkError.bookmarkNotFound(longKey)) {
            try await bookmarkStore.getBookmark(for: longKey)
        }
    }
    
    // MARK: - File Bookmark Tests
    
    @Test func saveBookmarkForFile() async throws {
        // Given
        let testFile = tempDirectory.appendingPathComponent("test-file.txt")
        try "test content".write(to: testFile, atomically: true, encoding: .utf8)
        let key = "file-key"
        
        // When
        try await bookmarkStore.saveBookmark(testFile, for: key)
        
        // Then
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == testFile.standardizedFileURL.path)
    }
    
    @Test func saveBookmarkForFileVerifiesAccessibility() async throws {
        // Given
        let testFile = tempDirectory.appendingPathComponent("accessible-file.txt")
        try "accessible content".write(to: testFile, atomically: true, encoding: .utf8)
        let key = "accessible-file-key"
        
        // When & Then - should not throw when file is accessible
        try await bookmarkStore.saveBookmark(testFile, for: key)
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == testFile.standardizedFileURL.path)
    }
    
    @Test func saveBookmarkForFileWithExtension() async throws {
        // Given - file with extension should be detected as file even without resource values
        let testFile = tempDirectory.appendingPathComponent("test.nml")
        try "test data".write(to: testFile, atomically: true, encoding: .utf8)
        let key = "nml-file-key"
        
        // When
        try await bookmarkStore.saveBookmark(testFile, for: key)
        
        // Then
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == testFile.standardizedFileURL.path)
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
    
    @Test func getBookmarkHandlesNonSecurityScopedBookmark() async throws {
        // Given - create a bookmark without security scope manually
        let testFile = tempDirectory.appendingPathComponent("non-scoped-file.txt")
        try "test".write(to: testFile, atomically: true, encoding: .utf8)
        let key = "non-scoped-key"
        
        // Create bookmark data without security scope
        let bookmarkData = try testFile.bookmarkData(
            options: [],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        UserDefaults.standard.set(bookmarkData, forKey: key)
        
        // When - getBookmark should handle both security-scoped and non-security-scoped bookmarks
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        
        // Then
        #expect(retrievedURL.standardizedFileURL.path == testFile.standardizedFileURL.path)
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
        
        // When
        let notFoundDescription = notFoundError.localizedDescription
        
        // Then
        #expect(notFoundDescription == "Bookmark not found for key: \(key)")
    }
    
    // MARK: - Edge Cases
    
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
        // Use a unique long key to avoid conflicts with other tests
        let longKey = "long-" + String(repeating: "a", count: 1000)
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: longKey)
        let retrievedURL = try await bookmarkStore.getBookmark(for: longKey)
        
        // Then
        #expect(retrievedURL.standardizedFileURL.path == testURL.standardizedFileURL.path)
    }
    
    // MARK: - Bookmark Resolution Error Tests
    
    @Test func bookmarkResolutionError() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("resolution-error-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "resolution-error-key"
        
        // When - save valid bookmark first
        try await bookmarkStore.saveBookmark(testURL, for: key)
        
        // Corrupt the bookmark data in UserDefaults
        let corruptedData = Data("corrupted-bookmark-data".utf8)
        UserDefaults.standard.set(corruptedData, forKey: key)
        
        // Then - should throw error when trying to resolve corrupted bookmark
        await #expect(throws: Error.self) {
            try await bookmarkStore.getBookmark(for: key)
        }
    }
    
    // MARK: - Security Scope Resource Management Tests
    
    @Test func securityScopeResourceIsProperlyManaged() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("security-management-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "security-management-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        
        // Then - should be able to access and stop accessing security scoped resource
        #expect(retrievedURL.startAccessingSecurityScopedResource())
        retrievedURL.stopAccessingSecurityScopedResource()
        
        // Verify we can access it again
        #expect(retrievedURL.startAccessingSecurityScopedResource())
        retrievedURL.stopAccessingSecurityScopedResource()
    }
    
    @Test func multipleSecurityScopeAccesses() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("multiple-security-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "multiple-security-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        let retrievedURL1 = try await bookmarkStore.getBookmark(for: key)
        let retrievedURL2 = try await bookmarkStore.getBookmark(for: key)
        
        // Then - both URLs should be accessible independently
        #expect(retrievedURL1.startAccessingSecurityScopedResource())
        #expect(retrievedURL2.startAccessingSecurityScopedResource())
        
        retrievedURL1.stopAccessingSecurityScopedResource()
        retrievedURL2.stopAccessingSecurityScopedResource()
    }
    
    // MARK: - UserDefaults Integration Tests
    
    @Test func bookmarkDataIsStoredInUserDefaults() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("userdefaults-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "userdefaults-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        
        // Then - data should be stored in UserDefaults
        let storedData = UserDefaults.standard.data(forKey: key)
        #expect(storedData != nil)
        #expect(storedData!.count > 0)
    }
    
    @Test func bookmarkDataIsRetrievedFromUserDefaults() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("userdefaults-retrieval-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "userdefaults-retrieval-key"
        
        // When
        try await bookmarkStore.saveBookmark(testURL, for: key)
        
        // Clear UserDefaults to simulate fresh app launch
        UserDefaults.standard.removeObject(forKey: key)
        
        // Then - should throw error when bookmark is not found
        await #expect(throws: BookmarkError.bookmarkNotFound(key)) {
            try await bookmarkStore.getBookmark(for: key)
        }
    }
    
    // MARK: - Actor Concurrency Tests
    
    @Test func actorIsolation() async throws {
        // Given
        let testURL = tempDirectory.appendingPathComponent("actor-isolation-test")
        try FileManager.default.createDirectory(at: testURL, withIntermediateDirectories: true)
        let key = "actor-isolation-key"
        
        // When - multiple concurrent operations on the same actor
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                try? await self.bookmarkStore.saveBookmark(testURL, for: key)
            }
            group.addTask {
                _ = try? await self.bookmarkStore.getBookmark(for: key)
            }
            group.addTask {
                try? await self.bookmarkStore.saveBookmark(testURL, for: "\(key)-2")
            }
        }
        
        // Then - should be able to retrieve the bookmark
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == testURL.standardizedFileURL.path)
    }
    
    // MARK: - File vs Directory Detection Tests
    
    @Test func distinguishesFileFromDirectory() async throws {
        // Given - both a file and directory with same base name
        let testDir = tempDirectory.appendingPathComponent("test-item")
        let testFile = tempDirectory.appendingPathComponent("test-item.txt")
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        try "content".write(to: testFile, atomically: true, encoding: .utf8)
        
        let dirKey = "dir-key"
        let fileKey = "file-key"
        
        // When
        try await bookmarkStore.saveBookmark(testDir, for: dirKey)
        try await bookmarkStore.saveBookmark(testFile, for: fileKey)
        
        // Then
        let retrievedDir = try await bookmarkStore.getBookmark(for: dirKey)
        let retrievedFile = try await bookmarkStore.getBookmark(for: fileKey)
        
        #expect(retrievedDir.standardizedFileURL.path == testDir.standardizedFileURL.path)
        #expect(retrievedFile.standardizedFileURL.path == testFile.standardizedFileURL.path)
    }
    
    // MARK: - Synchronous Bookmark Creation Tests
    
    @Test func bookmarkCreationIsSynchronous() async throws {
        // Given
        let testFile = tempDirectory.appendingPathComponent("sync-test.txt")
        try "sync content".write(to: testFile, atomically: true, encoding: .utf8)
        let key = "sync-key"
        
        // When - save should complete immediately (synchronous bookmark creation)
        try await bookmarkStore.saveBookmark(testFile, for: key)
        
        // Then - bookmark should be immediately available
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == testFile.standardizedFileURL.path)
    }
    
    @Test func fileBookmarkFallsBackToNonSecurityScoped() async throws {
        // Given - a file that might fail security-scoped bookmark creation
        // Note: This test verifies the fallback logic exists, though in normal
        // circumstances security-scoped bookmarks should work
        let testFile = tempDirectory.appendingPathComponent("fallback-test.txt")
        try "fallback content".write(to: testFile, atomically: true, encoding: .utf8)
        let key = "fallback-key"
        
        // When
        try await bookmarkStore.saveBookmark(testFile, for: key)
        
        // Then - should be retrievable (whether security-scoped or not)
        let retrievedURL = try await bookmarkStore.getBookmark(for: key)
        #expect(retrievedURL.standardizedFileURL.path == testFile.standardizedFileURL.path)
    }
}
