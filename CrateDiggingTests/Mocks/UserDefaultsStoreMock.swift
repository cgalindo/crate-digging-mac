//
//  UserDefaultsStoreMock.swift
//  CrateDiggingTests
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation
@testable import CrateDigging

/// Black box mock implementation of UserDefaultsStore for testing
final class UserDefaultsStoreMock: @unchecked Sendable, UserDefaultsStorage {
    // MARK: - Storage
    
    private var storage: [String: Any] = [:]
    
    // MARK: - UserDefaultsStore Implementation
    
    func set(_ value: Any?, forKey defaultName: String) {
        if let value = value {
            storage[defaultName] = value
        } else {
            storage.removeValue(forKey: defaultName)
        }
    }
    
    func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }
    
    func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }
    
    func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
}

