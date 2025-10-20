//
//  TraktorFolderRepositoryTests.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 10/19/25.
//

import Foundation
import Testing
@testable import CrateFoundation

struct TraktorFolderRepositoryTests {
    
    // MARK: - Save Bookmark Tests
    
    @Test func saveBookmarkSuccess() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let testURL = URL(fileURLWithPath: "/test/path")
        let testKey = "test-key"
        let bookmark = Bookmark(url: testURL, key: testKey)
        
        // When
        try await repository.save(bookmark)
        
        // Then
        #expect(await mockBookmarkStore.hasBookmark(for: testKey))
        #expect(await mockBookmarkStore.getStoredBookmarkCount() == 1)
    }
    
    @Test func saveBookmarkWithMultipleBookmarks() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let bookmark1 = Bookmark(url: URL(fileURLWithPath: "/test/path1"), key: "key1")
        let bookmark2 = Bookmark(url: URL(fileURLWithPath: "/test/path2"), key: "key2")
        
        // When
        try await repository.save(bookmark1)
        try await repository.save(bookmark2)
        
        // Then
        #expect(await mockBookmarkStore.hasBookmark(for: "key1"))
        #expect(await mockBookmarkStore.hasBookmark(for: "key2"))
        #expect(await mockBookmarkStore.getStoredBookmarkCount() == 2)
    }
    
    @Test func saveBookmarkOverwritesExisting() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let originalURL = URL(fileURLWithPath: "/original/path")
        let newURL = URL(fileURLWithPath: "/new/path")
        let key = "overwrite-key"
        
        let originalBookmark = Bookmark(url: originalURL, key: key)
        let newBookmark = Bookmark(url: newURL, key: key)
        
        // When
        try await repository.save(originalBookmark)
        try await repository.save(newBookmark)
        
        // Then
        #expect(await mockBookmarkStore.hasBookmark(for: key))
        #expect(await mockBookmarkStore.getStoredBookmarkCount() == 1)
    }
    
    @Test func saveBookmarkPropagatesError() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let testError = BookmarkError.emptyKey
        let bookmark = Bookmark(url: URL(fileURLWithPath: "/test/path"), key: "test-key")
        
        await mockBookmarkStore.setShouldThrowError(true, error: testError)
        
        // When & Then
        await #expect(throws: BookmarkError.emptyKey) {
            try await repository.save(bookmark)
        }
    }
    
    @Test func saveBookmarkWithEmptyKey() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let bookmark = Bookmark(url: URL(fileURLWithPath: "/test/path"), key: "")
        
        await mockBookmarkStore.setShouldThrowError(true, error: BookmarkError.emptyKey)
        
        // When & Then
        await #expect(throws: BookmarkError.emptyKey) {
            try await repository.save(bookmark)
        }
    }
    
    // MARK: - Fetch Bookmark Tests
    
    @Test func fetchBookmarkSuccess() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let testURL = URL(fileURLWithPath: "/test/path")
        let testKey = "test-key"
        
        // Pre-populate the mock store
        try await mockBookmarkStore.saveBookmark(testURL, for: testKey)
        
        // When
        let result = try await repository.fetchBookmark(for: testKey)
        
        // Then
        #expect(result == testURL.absoluteString)
    }
    
    @Test func fetchBookmarkWithMultipleKeys() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let url1 = URL(fileURLWithPath: "/test/path1")
        let url2 = URL(fileURLWithPath: "/test/path2")
        let key1 = "key1"
        let key2 = "key2"
        
        // Pre-populate the mock store
        try await mockBookmarkStore.saveBookmark(url1, for: key1)
        try await mockBookmarkStore.saveBookmark(url2, for: key2)
        
        // When
        let result1 = try await repository.fetchBookmark(for: key1)
        let result2 = try await repository.fetchBookmark(for: key2)
        
        // Then
        #expect(result1 == url1.absoluteString)
        #expect(result2 == url2.absoluteString)
    }
    
    @Test func fetchBookmarkThrowsErrorForNonExistentKey() async {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let nonExistentKey = "non-existent-key"
        
        // When & Then
        await #expect(throws: BookmarkError.bookmarkNotFound(nonExistentKey)) {
            try await repository.fetchBookmark(for: nonExistentKey)
        }
    }
    
    @Test func fetchBookmarkPropagatesError() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let testError = BookmarkError.emptyKey
        let testKey = "test-key"
        
        await mockBookmarkStore.setShouldThrowError(true, error: testError)
        
        // When & Then
        await #expect(throws: BookmarkError.emptyKey) {
            try await repository.fetchBookmark(for: testKey)
        }
    }
    
    // MARK: - Integration Tests
    
    @Test func saveAndFetchBookmarkRoundTrip() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let testURL = URL(fileURLWithPath: "/test/roundtrip/path")
        let testKey = "roundtrip-key"
        let bookmark = Bookmark(url: testURL, key: testKey)
        
        // When
        try await repository.save(bookmark)
        let result = try await repository.fetchBookmark(for: testKey)
        
        // Then
        #expect(result == testURL.absoluteString)
    }
    
    @Test func multipleSaveAndFetchOperations() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let bookmarks = (0..<5).map { index in
            Bookmark(url: URL(fileURLWithPath: "/test/path\(index)"), key: "key\(index)")
        }
        
        // When - Save all bookmarks
        for bookmark in bookmarks {
            try await repository.save(bookmark)
        }
        
        // Then - Fetch all bookmarks
        for bookmark in bookmarks {
            let result = try await repository.fetchBookmark(for: bookmark.key)
            #expect(result == bookmark.url.absoluteString)
        }
        
        #expect(await mockBookmarkStore.getStoredBookmarkCount() == 5)
    }
    
    // MARK: - Edge Cases
    
    @Test func saveBookmarkWithSpecialCharactersInKey() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let specialKey = "key-with-special-chars!@#$%^&*()"
        let testURL = URL(fileURLWithPath: "/test/special/path")
        let bookmark = Bookmark(url: testURL, key: specialKey)
        
        // When
        try await repository.save(bookmark)
        let result = try await repository.fetchBookmark(for: specialKey)
        
        // Then
        #expect(result == testURL.absoluteString)
        #expect(await mockBookmarkStore.hasBookmark(for: specialKey))
    }
    
    @Test func saveBookmarkWithLongKey() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let longKey = String(repeating: "a", count: 1000)
        let testURL = URL(fileURLWithPath: "/test/long/path")
        let bookmark = Bookmark(url: testURL, key: longKey)
        
        // When
        try await repository.save(bookmark)
        let result = try await repository.fetchBookmark(for: longKey)
        
        // Then
        #expect(result == testURL.absoluteString)
        #expect(await mockBookmarkStore.hasBookmark(for: longKey))
    }
    
    @Test func saveBookmarkWithComplexURL() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let complexURL = URL(string: "file:///Users/test/Documents/My%20Music%20Collection/2024/January%2015th/")!
        let testKey = "complex-url-key"
        let bookmark = Bookmark(url: complexURL, key: testKey)
        
        // When
        try await repository.save(bookmark)
        let result = try await repository.fetchBookmark(for: testKey)
        
        // Then
        #expect(result == complexURL.absoluteString)
        #expect(await mockBookmarkStore.hasBookmark(for: testKey))
    }
    
    // MARK: - Concurrent Access Tests
    
    @Test func concurrentSaveOperations() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let bookmarks = (0..<10).map { index in
            Bookmark(url: URL(fileURLWithPath: "/concurrent/path\(index)"), key: "concurrent-key\(index)")
        }
        
        // When - Save all bookmarks concurrently
        await withTaskGroup(of: Void.self) { group in
            for bookmark in bookmarks {
                group.addTask {
                    try? await repository.save(bookmark)
                }
            }
        }
        
        // Then
        #expect(await mockBookmarkStore.getStoredBookmarkCount() == 10)
        
        // Verify all bookmarks can be fetched
        for bookmark in bookmarks {
            let result = try await repository.fetchBookmark(for: bookmark.key)
            #expect(result == bookmark.url.absoluteString)
        }
    }
    
    @Test func concurrentSaveAndFetchOperations() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let bookmarks = (0..<5).map { index in
            Bookmark(url: URL(fileURLWithPath: "/mixed/path\(index)"), key: "mixed-key\(index)")
        }
        
        // When - Mix of save and fetch operations
        await withTaskGroup(of: Void.self) { group in
            // Save first batch
            for bookmark in bookmarks.prefix(3) {
                group.addTask {
                    try? await repository.save(bookmark)
                }
            }
            
            // Fetch operations (will fail for non-existent keys initially)
            for bookmark in bookmarks {
                group.addTask {
                    _ = try? await repository.fetchBookmark(for: bookmark.key)
                }
            }
            
            // Save remaining bookmarks
            for bookmark in bookmarks.suffix(2) {
                group.addTask {
                    try? await repository.save(bookmark)
                }
            }
        }
        
        // Then - All bookmarks should be saved
        #expect(await mockBookmarkStore.getStoredBookmarkCount() == 5)
    }
    
    // MARK: - Error Recovery Tests
    
    @Test func saveBookmarkRecoversFromError() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let testError = BookmarkError.emptyKey
        let bookmark = Bookmark(url: URL(fileURLWithPath: "/test/path"), key: "test-key")
        
        // When - First attempt fails
        await mockBookmarkStore.setShouldThrowError(true, error: testError)
        await #expect(throws: BookmarkError.emptyKey) {
            try await repository.save(bookmark)
        }
        
        // Then - Recovery succeeds
        await mockBookmarkStore.setShouldThrowError(false)
        try await repository.save(bookmark)
        
        #expect(await mockBookmarkStore.hasBookmark(for: "test-key"))
    }
    
    @Test func fetchBookmarkRecoversFromError() async throws {
        // Given
        let mockBookmarkStore = DefaultBookmarkStoreMock()
        let repository = TraktorFolderRepository(bookmarkStore: mockBookmarkStore)
        let testURL = URL(fileURLWithPath: "/test/path")
        let testKey = "test-key"
        
        // Pre-populate the mock store
        try await mockBookmarkStore.saveBookmark(testURL, for: testKey)
        
        // When - First attempt fails
        await mockBookmarkStore.setShouldThrowError(true, error: BookmarkError.emptyKey)
        await #expect(throws: BookmarkError.emptyKey) {
            try await repository.fetchBookmark(for: testKey)
        }
        
        // Then - Recovery succeeds
        await mockBookmarkStore.setShouldThrowError(false)
        let result = try await repository.fetchBookmark(for: testKey)
        #expect(result == testURL.absoluteString)
    }
}
