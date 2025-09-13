//
//  MixesMenuItem.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

// MARK: - Mixes Menu Item Model
struct MixesMenuItem: Equatable {
    let id = UUID()
    let title = "Mixes"
    let mixCount = 0
    
    static func == (lhs: MixesMenuItem, rhs: MixesMenuItem) -> Bool {
        return lhs.id == rhs.id
    }
}
