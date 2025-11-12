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
    
    func setBookmark(_ value: String, for key: String) {
        bookmarks[key] = value
    }
    
    func save(_ bookmark: Bookmark) async throws {
        savedBookmarks.append(bookmark)
        bookmarks[bookmark.key] = bookmark.url.absoluteString
    }
    
    func fetchBookmark(for key: String) async throws -> String {
        guard let value = bookmarks[key] else {
            throw MockError.missing
        }
        return value
    }
}
