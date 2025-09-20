//
//  FilterOptions.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/19/25.
//

import Foundation

// MARK: - Filter Models
struct FilterOptions: Equatable {
    var searchText: String = ""
    var selectedGenres: Set<String> = []
    var bpmRange: ClosedRange<Int> = 60...200
    var isActive: Bool {
        !searchText.isEmpty || !selectedGenres.isEmpty || bpmRange != 60...200
    }
}

// MARK: - Filter Actions
enum FilterAction {
    case updateSearch(String)
    case toggleGenre(String)
    case updateBPMRange(ClosedRange<Int>)
    case clearAll
}

