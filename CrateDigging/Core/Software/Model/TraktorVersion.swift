//
//  TraktorVersion.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

struct TraktorVersion: Codable, Identifiable, Comparable, Equatable {
    let id: String
    let version: String
    let folderName: String
    let isSelected: Bool
    
    init(
        version: String,
        folderName: String,
        isSelected: Bool = false
    ) {
        self.id = folderName
        self.version = version
        self.folderName = folderName
        self.isSelected = isSelected
    }
    
    static func compareVersions(_ version1: String, _ version2: String) -> Int {
        let components1 = version1.split(separator: ".").compactMap { Int($0) }
        let components2 = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxCount = max(components1.count, components2.count)
        
        for i in 0..<maxCount {
            let value1 = i < components1.count ? components1[i] : 0
            let value2 = i < components2.count ? components2[i] : 0
            
            if value1 < value2 {
                return -1
            } else if value1 > value2 {
                return 1
            }
        }
        
        return 0
    }
}

// Compare versions (e.g., "4.1.1" > "4.0.5")
func < (lhs: TraktorVersion, rhs: TraktorVersion) -> Bool {
    TraktorVersion.compareVersions(lhs.version, rhs.version) < 0
}

struct TraktorVersions: Codable {
    var versions: [TraktorVersion]
    var selectedVersionId: String?
    
    var selectedVersion: TraktorVersion? {
        if let selectedId = selectedVersionId,
           let foundVersion = versions.first(where: { $0.id == selectedId }) {
            return foundVersion
        }
        return versions.max()
    }
}


