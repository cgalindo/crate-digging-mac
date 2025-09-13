//
//  CollectionMenuItem.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

// MARK: - Collection Menu Item Model
struct CollectionMenuItem: Equatable {
    let id = UUID()
    let title = "Music Collection"
    let itemCount = 0
    
    static func == (lhs: CollectionMenuItem, rhs: CollectionMenuItem) -> Bool {
        return lhs.id == rhs.id
    }
}
