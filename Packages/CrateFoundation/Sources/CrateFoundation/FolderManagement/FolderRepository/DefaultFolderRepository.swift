//
//  DefaultFolderRepository.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 9/27/25.
//

import Foundation
import OSLog

public struct DefaultFolderRepository: FolderRepository {
    
    private let bookmarkStore: any BookmarkStore
    
    /// Public initializer that uses the default bookmark store.
    /// Use this for production code. The bookmark store implementation is internal.
    public init() {
        self.bookmarkStore = DefaultBookmarkStore()
    }
    
    /// Internal initializer for testing purposes only.
    /// Allows injection of a custom bookmark store for testing.
    init(bookmarkStore: any BookmarkStore) {
        self.bookmarkStore = bookmarkStore
    }
    
    public func save(_ bookmark: Bookmark) async throws {
        do {
            try await bookmarkStore.saveBookmark(bookmark.url, for: bookmark.key)
            Logger.folderManagement.debug("Successfully saved bookmark.")
        } catch {
            Logger.folderManagement.error("Failed to save bookmark: \(error)")
            throw error
        }
    }
    
    public func fetchBookmark(for key: String) async throws -> String {
        return try await bookmarkStore.getBookmark(for: key).absoluteString
    }
    
    public func removeBookmark(for key: String) async throws {
        do {
            try await bookmarkStore.removeBookmark(for: key)
            Logger.folderManagement.debug("Successfully removed bookmark.")
        } catch {
            Logger.folderManagement.error("Failed to remove bookmark: \(error)")
            throw error
        }
    }
}

