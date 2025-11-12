//
//  UserDefaultsStore.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

/// Default implementation of UserDefaultsStore using UserDefaults.standard
struct UserDefaultsStore: UserDefaultsStorage {
    var userDefaults: UserDefaults {
        .standard
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }
    
    func data(forKey defaultName: String) -> Data? {
        return userDefaults.data(forKey: defaultName)
    }
    
    func string(forKey defaultName: String) -> String? {
        return userDefaults.string(forKey: defaultName)
    }
    
    func removeObject(forKey defaultName: String) {
        userDefaults.removeObject(forKey: defaultName)
    }
}
