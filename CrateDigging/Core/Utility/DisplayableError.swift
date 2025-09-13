//
//  DisplayableError.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

enum DisplayableError: Error {
    case unknown
    
    var message: String {
        switch self {
        case .unknown:
            return "Apologies, an unknown error occurred."
        }
    }
}
