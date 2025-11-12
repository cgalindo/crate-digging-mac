//
//  ClearAllDataUseCase.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation
import CrateFoundation

protocol ClearAllDataUseCase: Sendable {
    /// Clears all saved bookmarks and user defaults
    func callAsFunction()
}

struct DefaultClearAllDataUseCase: ClearAllDataUseCase {
    private let bookmarkKeys: [String]
    private let userDefaultKeys: [String]
    private let userDefaults: any UserDefaultsStorage
    
    init(
        bookmarkKeys: [String],
        userDefaultKeys: [String],
        userDefaults: any UserDefaultsStorage = UserDefaultsStore()
    ) {
        self.bookmarkKeys = bookmarkKeys
        self.userDefaultKeys = userDefaultKeys
        self.userDefaults = userDefaults
    }
    
    func callAsFunction() {
        // Clear all bookmark keys from UserDefaults
        // (BookmarkStore stores bookmarks in UserDefaults)
        for key in bookmarkKeys {
            userDefaults.removeObject(forKey: key)
        }
        
        // Clear other UserDefaults keys
        for key in userDefaultKeys {
            userDefaults.removeObject(forKey: key)
        }
    }
}

