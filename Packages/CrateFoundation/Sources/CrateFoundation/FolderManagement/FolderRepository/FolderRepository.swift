//
//  FolderRepository.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 9/27/25.
//

import Foundation

/// Handles folder management for Traktor collection.
public protocol FolderRepository: Sendable {
    
    func save(_ bookmark: Bookmark) async throws
    
    func fetchBookmark(for key: String) async throws -> String
}
