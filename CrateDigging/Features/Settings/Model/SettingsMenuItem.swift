//
//  SettingsMenuItem.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

// MARK: - Settings Menu Item Model
struct SettingsMenuItem: Equatable {
    let id = UUID()
    let title = "Settings"
    
    static func == (lhs: SettingsMenuItem, rhs: SettingsMenuItem) -> Bool {
        return lhs.id == rhs.id
    }
}
