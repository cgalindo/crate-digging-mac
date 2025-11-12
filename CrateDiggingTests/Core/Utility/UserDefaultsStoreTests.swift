//
//  UserDefaultsStoreTests.swift
//  CrateDiggingTests
//
//  Created by ChatGPT on 11/11/25.
//

import Testing
@testable import CrateDigging
import Foundation

struct UserDefaultsStoreTests {
    private let store = UserDefaultsStore()
    private let userDefaults = UserDefaults.standard
    
    @Test func setStoresAndRetrievesString() {
        let key = "test.string.\(UUID().uuidString)"
        let expectedValue = "crate-digging"
        
        store.set(expectedValue, forKey: key)
        defer { userDefaults.removeObject(forKey: key) }
        
        #expect(store.string(forKey: key) == expectedValue)
    }
    
    @Test func setStoresAndRetrievesData() {
        let key = "test.data.\(UUID().uuidString)"
        let expectedValue = Data("crate-data".utf8)
        
        store.set(expectedValue, forKey: key)
        defer { userDefaults.removeObject(forKey: key) }
        
        #expect(store.data(forKey: key) == expectedValue)
    }
    
    @Test func removeObjectClearsStoredValue() {
        let key = "test.remove.\(UUID().uuidString)"
        store.set("to-be-removed", forKey: key)
        
        store.removeObject(forKey: key)
        
        #expect(store.string(forKey: key) == nil)
    }
}
