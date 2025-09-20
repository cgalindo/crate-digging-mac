//
//  CollectionToolBarItem.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/18/25.
//

import Foundation

enum CollectionToolBarItem {
    case filter
    case search
    

    var imageName: String {
        switch self {
        case .filter:
            return "filter"
        case .search:
            return "search"
        }
    }
}
