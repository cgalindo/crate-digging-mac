//
//  Bookmark.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 10/7/25.
//

import Foundation

public struct Bookmark: Sendable {
    let url: URL
    let key: String
    
    public init(
        url: URL,
        key: String
    ) {
        self.url = url
        self.key = key
    }
}
