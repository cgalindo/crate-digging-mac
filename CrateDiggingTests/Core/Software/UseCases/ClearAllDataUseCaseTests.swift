//
//  ClearAllDataUseCaseTests.swift
//  CrateDiggingTests
//
//  Created by Chris Galindo on 9/13/25.
//

import Testing
@testable import CrateDigging
import Foundation

struct ClearAllDataUseCaseTests {
    
    // MARK: - Clear Bookmark Keys Tests
    
    @Test func clearsAllBookmarkKeys() {
        // Given
        let bookmarkKey1 = "test.bookmark.key1"
        let bookmarkKey2 = "test.bookmark.key2"
        let bookmarkKey3 = "test.bookmark.key3"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        // Pre-populate UserDefaults with bookmark data
        let bookmarkData1 = Data("bookmark1".utf8)
        let bookmarkData2 = Data("bookmark2".utf8)
        let bookmarkData3 = Data("bookmark3".utf8)
        userDefaultsMock.set(bookmarkData1, forKey: bookmarkKey1)
        userDefaultsMock.set(bookmarkData2, forKey: bookmarkKey2)
        userDefaultsMock.set(bookmarkData3, forKey: bookmarkKey3)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [bookmarkKey1, bookmarkKey2, bookmarkKey3],
            userDefaultKeys: [],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - all bookmark keys should be cleared
        #expect(userDefaultsMock.data(forKey: bookmarkKey1) == nil)
        #expect(userDefaultsMock.data(forKey: bookmarkKey2) == nil)
        #expect(userDefaultsMock.data(forKey: bookmarkKey3) == nil)
    }
    
    @Test func clearsBookmarkKeysButNotOtherKeys() {
        // Given
        let bookmarkKey = "test.bookmark.key"
        let otherKey = "test.other.key"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        // Pre-populate UserDefaults
        userDefaultsMock.set(Data("bookmark".utf8), forKey: bookmarkKey)
        userDefaultsMock.set("other-value", forKey: otherKey)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [bookmarkKey],
            userDefaultKeys: [],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - bookmark key should be cleared, other key should remain
        #expect(userDefaultsMock.data(forKey: bookmarkKey) == nil)
        #expect(userDefaultsMock.string(forKey: otherKey) == "other-value")
    }
    
    @Test func clearsEmptyBookmarkKeysArray() {
        // Given
        let userDefaultsMock = UserDefaultsStoreMock()
        userDefaultsMock.set("some-value", forKey: "some.key")
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [],
            userDefaultKeys: [],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - should not affect existing keys
        #expect(userDefaultsMock.string(forKey: "some.key") == "some-value")
    }
    
    // MARK: - Clear User Default Keys Tests
    
    @Test func clearsAllUserDefaultKeys() {
        // Given
        let userDefaultKey1 = "test.userdefault.key1"
        let userDefaultKey2 = "test.userdefault.key2"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        // Pre-populate UserDefaults
        userDefaultsMock.set("value1", forKey: userDefaultKey1)
        userDefaultsMock.set("value2", forKey: userDefaultKey2)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [],
            userDefaultKeys: [userDefaultKey1, userDefaultKey2],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - all user default keys should be cleared
        #expect(userDefaultsMock.string(forKey: userDefaultKey1) == nil)
        #expect(userDefaultsMock.string(forKey: userDefaultKey2) == nil)
    }
    
    @Test func clearsUserDefaultKeysButNotOtherKeys() {
        // Given
        let userDefaultKey = "test.userdefault.key"
        let otherKey = "test.other.key"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        // Pre-populate UserDefaults
        userDefaultsMock.set("userdefault-value", forKey: userDefaultKey)
        userDefaultsMock.set("other-value", forKey: otherKey)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [],
            userDefaultKeys: [userDefaultKey],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - user default key should be cleared, other key should remain
        #expect(userDefaultsMock.string(forKey: userDefaultKey) == nil)
        #expect(userDefaultsMock.string(forKey: otherKey) == "other-value")
    }
    
    @Test func clearsEmptyUserDefaultKeysArray() {
        // Given
        let userDefaultsMock = UserDefaultsStoreMock()
        userDefaultsMock.set("some-value", forKey: "some.key")
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [],
            userDefaultKeys: [],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - should not affect existing keys
        #expect(userDefaultsMock.string(forKey: "some.key") == "some-value")
    }
    
    // MARK: - Clear Both Bookmark and User Default Keys Tests
    
    @Test func clearsBothBookmarkAndUserDefaultKeys() {
        // Given
        let bookmarkKey1 = "test.bookmark.key1"
        let bookmarkKey2 = "test.bookmark.key2"
        let userDefaultKey1 = "test.userdefault.key1"
        let userDefaultKey2 = "test.userdefault.key2"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        // Pre-populate UserDefaults
        userDefaultsMock.set(Data("bookmark1".utf8), forKey: bookmarkKey1)
        userDefaultsMock.set(Data("bookmark2".utf8), forKey: bookmarkKey2)
        userDefaultsMock.set("userdefault1", forKey: userDefaultKey1)
        userDefaultsMock.set("userdefault2", forKey: userDefaultKey2)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [bookmarkKey1, bookmarkKey2],
            userDefaultKeys: [userDefaultKey1, userDefaultKey2],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - all keys should be cleared
        #expect(userDefaultsMock.data(forKey: bookmarkKey1) == nil)
        #expect(userDefaultsMock.data(forKey: bookmarkKey2) == nil)
        #expect(userDefaultsMock.string(forKey: userDefaultKey1) == nil)
        #expect(userDefaultsMock.string(forKey: userDefaultKey2) == nil)
    }
    
    @Test func clearsMixedKeysButPreservesUnlistedKeys() {
        // Given
        let bookmarkKey = "test.bookmark.key"
        let userDefaultKey = "test.userdefault.key"
        let preservedKey = "test.preserved.key"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        // Pre-populate UserDefaults
        userDefaultsMock.set(Data("bookmark".utf8), forKey: bookmarkKey)
        userDefaultsMock.set("userdefault", forKey: userDefaultKey)
        userDefaultsMock.set("preserved", forKey: preservedKey)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [bookmarkKey],
            userDefaultKeys: [userDefaultKey],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - listed keys should be cleared, preserved key should remain
        #expect(userDefaultsMock.data(forKey: bookmarkKey) == nil)
        #expect(userDefaultsMock.string(forKey: userDefaultKey) == nil)
        #expect(userDefaultsMock.string(forKey: preservedKey) == "preserved")
    }
    
    // MARK: - Real-World Scenario Tests
    
    @Test func clearsTraktorBookmarkAndUserDefaultKeys() {
        // Given
        let rootFolderKey = TraktorPanelItem.rootFolder.storeKey
        let historyFolderKey = TraktorPanelItem.historyFolder.storeKey
        let collectionKey = TraktorPanelItem.collection.storeKey
        let versionsKey = "traktor.versions"
        let selectedVersionKey = "traktor.selectedVersion"
        
        let userDefaultsMock = UserDefaultsStoreMock()
        
        // Pre-populate with realistic data
        userDefaultsMock.set(Data("root-bookmark".utf8), forKey: rootFolderKey)
        userDefaultsMock.set(Data("history-bookmark".utf8), forKey: historyFolderKey)
        userDefaultsMock.set(Data("collection-bookmark".utf8), forKey: collectionKey)
        userDefaultsMock.set(Data("versions-data".utf8), forKey: versionsKey)
        userDefaultsMock.set("Traktor 4.1.1", forKey: selectedVersionKey)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [rootFolderKey, historyFolderKey, collectionKey],
            userDefaultKeys: [versionsKey, selectedVersionKey],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - all Traktor-related keys should be cleared
        #expect(userDefaultsMock.data(forKey: rootFolderKey) == nil)
        #expect(userDefaultsMock.data(forKey: historyFolderKey) == nil)
        #expect(userDefaultsMock.data(forKey: collectionKey) == nil)
        #expect(userDefaultsMock.data(forKey: versionsKey) == nil)
        #expect(userDefaultsMock.string(forKey: selectedVersionKey) == nil)
    }
    
    // MARK: - Edge Cases
    
    @Test func handlesNonExistentKeys() {
        // Given
        let nonExistentBookmarkKey = "non.existent.bookmark.key"
        let nonExistentUserDefaultKey = "non.existent.userdefault.key"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [nonExistentBookmarkKey],
            userDefaultKeys: [nonExistentUserDefaultKey],
            userDefaults: userDefaultsMock
        )
        
        // When - should not throw error
        useCase()
        
        // Then - keys should still be nil (no-op for non-existent keys)
        #expect(userDefaultsMock.data(forKey: nonExistentBookmarkKey) == nil)
        #expect(userDefaultsMock.string(forKey: nonExistentUserDefaultKey) == nil)
    }
    
    @Test func handlesDuplicateKeys() {
        // Given
        let duplicateKey = "test.duplicate.key"
        let userDefaultsMock = UserDefaultsStoreMock()
        userDefaultsMock.set("value", forKey: duplicateKey)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [duplicateKey],
            userDefaultKeys: [duplicateKey],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - key should be cleared (removed twice, but result is the same)
        #expect(userDefaultsMock.string(forKey: duplicateKey) == nil)
    }
    
    @Test func clearsAllKeysInProvidedArrays() {
        // Given
        let key1 = "test.key1"
        let key2 = "test.key2"
        let key3 = "test.key3"
        let userDefaultsMock = UserDefaultsStoreMock()
        
        userDefaultsMock.set("value1", forKey: key1)
        userDefaultsMock.set("value2", forKey: key2)
        userDefaultsMock.set("value3", forKey: key3)
        
        let useCase = DefaultClearAllDataUseCase(
            bookmarkKeys: [key1, key2, key3],
            userDefaultKeys: [],
            userDefaults: userDefaultsMock
        )
        
        // When
        useCase()
        
        // Then - all keys should be cleared
        #expect(userDefaultsMock.string(forKey: key1) == nil)
        #expect(userDefaultsMock.string(forKey: key2) == nil)
        #expect(userDefaultsMock.string(forKey: key3) == nil)
    }
}
