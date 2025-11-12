//
//  DefaultBookmarkStoreMock.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 10/20/25.
//

import Foundation

/// Black box mock implementation of BookmarkStore for testing DefaultFolderRepository
actor DefaultBookmarkStoreMock: BookmarkStore {
    private var bookmarks: [String: URL] = [:]
    private var shouldThrowError: Bool = false
    private var errorToThrow: Error = BookmarkError.bookmarkNotFound("")
    
    func getBookmark(for key: String) async throws -> URL {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let url = bookmarks[key] else {
            throw BookmarkError.bookmarkNotFound(key)
        }
        
        return url
    }
    
    func saveBookmark(_ url: URL, for key: String) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        
        bookmarks[key] = url
    }
    
    func removeBookmark(for key: String) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard bookmarks[key] != nil else {
            throw BookmarkError.bookmarkNotFound(key)
        }
        
        bookmarks.removeValue(forKey: key)
    }
    
    // MARK: - Test Control Methods
    
    func setShouldThrowError(_ shouldThrow: Bool, error: Error = BookmarkError.bookmarkNotFound("")) {
        shouldThrowError = shouldThrow
        errorToThrow = error
    }
    
    func clearBookmarks() {
        bookmarks.removeAll()
    }
    
    func getStoredBookmarkCount() -> Int {
        return bookmarks.count
    }
    
    func hasBookmark(for key: String) -> Bool {
        return bookmarks[key] != nil
    }
}
