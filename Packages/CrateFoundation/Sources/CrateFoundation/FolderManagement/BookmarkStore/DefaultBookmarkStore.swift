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
        var url: URL
        
        // Try resolving with security scope first
        do {
            url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        } catch {
            // If that fails (e.g., bookmark was created without security scope), try without it
            url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
        }
        
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
        
        // Create bookmark data SYNCHRONOUSLY before any async operations
        // This is critical for files from NSOpenPanel where access must be maintained
        let bookmarkData = try createBookmarkDataSynchronously(from: url)
        
        // Store the bookmark data (this is the only async part, and it's trivial)
        UserDefaults.standard.set(bookmarkData, forKey: key)
    }
    
    func removeBookmark(for key: String) async throws {
        guard !key.isEmpty else {
            throw BookmarkError.emptyKey
        }
        
        // Check if bookmark exists before removing
        guard UserDefaults.standard.data(forKey: key) != nil else {
            throw BookmarkError.bookmarkNotFound(key)
        }
        
        // Remove the bookmark data from UserDefaults
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    /// Creates bookmark data synchronously from a URL.
    /// For files from NSOpenPanel, this must be called immediately after selection
    /// to ensure security-scoped access is still valid.
    private func createBookmarkDataSynchronously(from url: URL) throws -> Data {
        // Check if URL represents a file (not a directory)
        let isFile: Bool
        if let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey]),
           let isDirectory = resourceValues.isDirectory {
            isFile = !isDirectory
        } else {
            // Fallback: check if URL has file extension (heuristic)
            isFile = !url.pathExtension.isEmpty
        }
        
        // For files from NSOpenPanel, verify accessibility before creating bookmark
        if isFile {
            // Verify file is accessible by attempting to read it
            // This ensures we have proper access before creating the bookmark
            do {
                let fileHandle = try FileHandle(forReadingFrom: url)
                _ = try fileHandle.read(upToCount: 1)
                try fileHandle.close()
            } catch {
                throw error
            }
        }
        
        // Create the bookmark - try with security scope first
        do {
            return try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        } catch {
            // If creating with security scope fails for files, try without it
            // This creates a regular bookmark that won't require security scope access
            if isFile {
                return try url.bookmarkData(
                    options: [],
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
            } else {
                throw error
            }
        }
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
