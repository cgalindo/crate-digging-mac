//
//  FolderRepositoryMock.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 11/11/25.
//

import Foundation

actor FolderRepositoryMock: FolderRepository {
    enum MockError: Error {
        case missing
    }
    
    private var bookmarks: [String: String] = [:]
    private(set) var savedBookmarks: [Bookmark] = []
    private var shouldThrowError = false
    private var errorToThrow: Error?
    
    func setBookmark(_ value: String, for key: String) {
        bookmarks[key] = value
    }
    
    func setShouldThrowError(_ shouldThrow: Bool, error: Error? = nil) {
        shouldThrowError = shouldThrow
        errorToThrow = error
    }
    
    func save(_ bookmark: Bookmark) async throws {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        savedBookmarks.append(bookmark)
        bookmarks[bookmark.key] = bookmark.url.absoluteString
    }
    
    func fetchBookmark(for key: String) async throws -> String {
        guard let value = bookmarks[key] else {
            throw MockError.missing
        }
        return value
    }
    
    func removeBookmark(for key: String) async throws {
        guard bookmarks[key] != nil else {
            throw MockError.missing
        }
        bookmarks.removeValue(forKey: key)
    }
    
    func hasBookmark(for key: String) -> Bool {
        bookmarks[key] != nil
    }
    
    func getStoredBookmarkCount() -> Int {
        bookmarks.count
    }
}
