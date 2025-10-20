//
//  DefaultBookmarkStore.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/24/25.
//

import Foundation

actor DefaultBookmarkStore: BookmarkStore {
    func getBookmark(for key: String) async throws -> URL {
        guard let bookmarkData = UserDefaults.standard.data(forKey: key) else {
            throw BookmarkError.bookmarkNotFound(key)
        }
        
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        
        if isStale {
            // Re-save the bookmark if it's stale
            try await saveBookmark(url, for: key)
        }
        
        return url
    }
    
    func saveBookmark(_ url: URL, for key: String) async throws {
        guard !key.isEmpty else {
            throw BookmarkError.emptyKey
        }
        
        let bookmarkData = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        UserDefaults.standard.set(bookmarkData, forKey: key)
    }
}

public enum BookmarkError: Error, Equatable, LocalizedError {
    case bookmarkNotFound(String)
    case emptyKey
    
    public var errorDescription: String? {
        switch self {
        case .bookmarkNotFound(let key):
            return "Bookmark not found for key: \(key)"
        case .emptyKey:
            return "Key cannot be empty"
        }
    }
}
