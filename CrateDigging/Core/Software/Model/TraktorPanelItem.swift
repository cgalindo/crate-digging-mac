//
//  TraktorPanelItem.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 9/27/25.
//

import Foundation
import CrateFoundation

enum TraktorPanelItem: PanelItem, CaseIterable {
    
    case rootFolder
    case historyFolder
    case collection
    
    var title: String {
        switch self {
        case .rootFolder:
            return "Crate Digging needs access to the Native Instruments folder"
        case .historyFolder:
            return "Crate Digging needs access to the History folder"
        case .collection:
            return "Crate Digging needs access to collection"
        }
    }
    
    var message: String {
        switch self {
        case .rootFolder:
            return "Please select the Native Instruments folder to grant access."
        case .historyFolder:
            return "Please select the History folder to grant access."
        case .collection:
            return "Please select the collection.nml file to grant access."
        }
    }
    
    var prompt: String {
        return "Grant Access"
    }
    
    var directoryURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    var canChooseDirectories: Bool {
        switch self {
        case .rootFolder, .historyFolder:
            return true
        case .collection:
            return false
        }
    }
    
    var canChooseFiles: Bool {
        switch self {
        case .rootFolder, .historyFolder:
            return false
        case .collection:
            return true
        }
    }
    
    var allowsMultipleSelection: Bool {
        return false
    }
    
    var cancreateDirectories: Bool {
        return false
    }
    
    var storeKey: String {
        switch self {
        case .rootFolder:
            return "traktor.rootFolder"
        case .historyFolder:
            return "traktor.historyFolder"
        case .collection:
            return "traktor.collection"
        }
    }
}
