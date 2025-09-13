//
//  CratesMenuItem.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

// MARK: - Crates Menu Item Model
struct CratesMenuItem: Equatable {
    let id = UUID()
    let title = "Crates"
    let crateCount = 0
    
    static func == (lhs: CratesMenuItem, rhs: CratesMenuItem) -> Bool {
        return lhs.id == rhs.id
    }
}
