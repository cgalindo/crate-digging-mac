//
//  TraktorFolderRepository.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 9/27/25.
//

import Foundation
import OSLog

struct TraktorFolderRepository: FolderRepository {
    
    let bookmarkStore: any BookmarkStore
    
    public init(
        bookmarkStore: any BookmarkStore = DefaultBookmarkStore()
    ) {
        self.bookmarkStore = bookmarkStore
    }
    
    func save(_ bookmark: Bookmark) async throws {
        do {
            try await bookmarkStore.saveBookmark(bookmark.url, for: bookmark.key)
            Logger.folderManagement.debug("Successfully saved bookmark.")
        } catch {
            Logger.folderManagement.error("Failed to save bookmark: \(error)")
            throw error
        }
    }
    
    func fetchBookmark(for key: String) async throws -> String {
        return try await bookmarkStore.getBookmark(for: key).absoluteString
    }
}
