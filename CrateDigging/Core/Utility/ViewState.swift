//
//  ViewState.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

enum ViewState<T>: Equatable where T: Equatable {
    case loading
    case loaded(T)
    case error(DisplayableError)
    
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsData), .loaded(let rhsData)):
            return lhsData == rhsData
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
