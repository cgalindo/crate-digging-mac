//
//  BookmarkStore.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/24/25.
//

import Foundation

/// Store for bookmarked URLs.
protocol BookmarkStore: Sendable {
    /// Fetch a specific bookmarked URL.
    /// - Parameters:
    ///   - key: Key used to fetch bookmarked URL from the store
    func getBookmark(for key: String) async throws -> URL
    
    /// Stores a bookmarked URL.
    /// - Parameters:
    ///   - url: Bookmarked URL  to store.
    ///   - key: Key used to identify URL.
    func saveBookmark(_ url: URL, for key: String) async throws
    
    /// Removes a bookmarked URL.
    /// - Parameters:
    ///   - key: Key used to indentify URL.
    func removeBookmark(for key: String) async throws
}
