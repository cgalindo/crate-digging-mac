//
//  MenuItem.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

// MARK: - Menu Items
enum MenuItem: String, CaseIterable {
    case collection = "Collection"
    case crates = "Crates"
    case mixes = "Mixes"
    case settings = "Settings"
    
    var title: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .collection:
            return "music.note.list"
        case .crates:
            return "shippingbox"
        case .mixes:
            return "waveform"
        case .settings:
            return "gearshape"
        }
    }
}
