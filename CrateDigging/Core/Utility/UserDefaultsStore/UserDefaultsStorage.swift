//
//  UserDefaultsStorage.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

/// Protocol for UserDefaults operations, allowing for dependency injection and testing
protocol UserDefaultsStorage: Sendable {
    /// Sets the value of the specified default key to the specified value
    func set(_ value: Any?, forKey defaultName: String)
    
    /// Returns the data object associated with the specified key
    func data(forKey defaultName: String) -> Data?
    
    /// Returns the string associated with the specified key
    func string(forKey defaultName: String) -> String?
    
    /// Removes the value of the specified default key
    func removeObject(forKey defaultName: String)
}

