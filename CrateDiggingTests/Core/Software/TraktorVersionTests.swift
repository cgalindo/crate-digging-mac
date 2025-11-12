//
//  TraktorVersionTests.swift
//  CrateDiggingTests
//
//  Created by Chris Galindo on 9/13/25.
//

import Testing
@testable import CrateDigging
import Foundation

struct TraktorVersionTests {
    
    // MARK: - Initialization Tests
    
    @Test func initializerSetsCorrectProperties() {
        // Given
        let version = "4.1.1"
        let folderName = "Traktor 4.1.1"
        
        // When
        let traktorVersion = TraktorVersion(version: version, folderName: folderName)
        
        // Then
        #expect(traktorVersion.version == version)
        #expect(traktorVersion.folderName == folderName)
        #expect(traktorVersion.id == folderName)
        #expect(traktorVersion.isSelected == false)
    }
    
    @Test func initializerWithIsSelected() {
        // Given
        let version = "4.1.1"
        let folderName = "Traktor 4.1.1"
        
        // When
        let traktorVersion = TraktorVersion(version: version, folderName: folderName, isSelected: true)
        
        // Then
        #expect(traktorVersion.isSelected == true)
    }
    
    @Test func idMatchesFolderName() {
        // Given
        let folderName = "Traktor 3.5.2"
        let traktorVersion = TraktorVersion(version: "3.5.2", folderName: folderName)
        
        // Then
        #expect(traktorVersion.id == folderName)
    }
    
    // MARK: - Comparable Tests
    
    @Test func versionComparisonSameVersion() {
        // Given
        let version1 = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1")
        let version2 = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1")
        
        // Then
        #expect((version1 < version2) == false)
        #expect((version1 > version2) == false)
        #expect(version1 == version2)
    }
    
    @Test func versionComparisonPatchVersion() {
        // Given
        let version1 = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1")
        let version2 = TraktorVersion(version: "4.1.2", folderName: "Traktor 4.1.2")
        
        // Then
        #expect(version1 < version2)
        #expect(version2 > version1)
    }
    
    @Test func versionComparisonMinorVersion() {
        // Given
        let version1 = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1")
        let version2 = TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0")
        
        // Then
        #expect(version1 < version2)
        #expect(version2 > version1)
    }
    
    @Test func versionComparisonMajorVersion() {
        // Given
        let version1 = TraktorVersion(version: "3.5.2", folderName: "Traktor 3.5.2")
        let version2 = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1")
        
        // Then
        #expect(version1 < version2)
        #expect(version2 > version1)
    }
    
    @Test func versionComparisonWithDifferentLengths() {
        // Given
        let version1 = TraktorVersion(version: "4.1", folderName: "Traktor 4.1")
        let version2 = TraktorVersion(version: "4.1.0", folderName: "Traktor 4.1.0")
        
        // Then - should treat as equal (4.1 == 4.1.0)
        #expect((version1 < version2) == false)
        #expect((version1 > version2) == false)
    }
    
    @Test func versionComparisonMaxReturnsLatest() {
        // Given
        let versions = [
            TraktorVersion(version: "3.5.2", folderName: "Traktor 3.5.2"),
            TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1"),
            TraktorVersion(version: "4.0.5", folderName: "Traktor 4.0.5"),
            TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0")
        ]
        
        // When
        let maxVersion = versions.max()
        
        // Then
        #expect(maxVersion?.version == "4.2.0")
        #expect(maxVersion?.folderName == "Traktor 4.2.0")
    }
    
    @Test func versionComparisonSortedDescending() {
        // Given
        var versions = [
            TraktorVersion(version: "3.5.2", folderName: "Traktor 3.5.2"),
            TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1"),
            TraktorVersion(version: "4.0.5", folderName: "Traktor 4.0.5"),
            TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0")
        ]
        
        // When
        versions.sort(by: >)
        
        // Then
        #expect(versions[0].version == "4.2.0")
        #expect(versions[1].version == "4.1.1")
        #expect(versions[2].version == "4.0.5")
        #expect(versions[3].version == "3.5.2")
    }
    
    // MARK: - Codable Tests
    
    @Test func traktorVersionEncodesAndDecodes() throws {
        // Given
        let originalVersion = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1", isSelected: true)
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalVersion)
        
        let decoder = JSONDecoder()
        let decodedVersion = try decoder.decode(TraktorVersion.self, from: data)
        
        // Then
        #expect(decodedVersion.id == originalVersion.id)
        #expect(decodedVersion.version == originalVersion.version)
        #expect(decodedVersion.folderName == originalVersion.folderName)
        #expect(decodedVersion.isSelected == originalVersion.isSelected)
    }
    
    // MARK: - TraktorVersions Tests
    
    @Test func traktorVersionsSelectedVersionWithSelectedId() {
        // Given
        let versions = [
            TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1"),
            TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0"),
            TraktorVersion(version: "3.5.2", folderName: "Traktor 3.5.2")
        ]
        let traktorVersions = TraktorVersions(
            versions: versions,
            selectedVersionId: "Traktor 4.1.1"
        )
        
        // When
        let selectedVersion = traktorVersions.selectedVersion
        
        // Then
        #expect(selectedVersion?.version == "4.1.1")
        #expect(selectedVersion?.folderName == "Traktor 4.1.1")
    }
    
    @Test func traktorVersionsSelectedVersionWithoutSelectedId() {
        // Given
        let versions = [
            TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1"),
            TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0"),
            TraktorVersion(version: "3.5.2", folderName: "Traktor 3.5.2")
        ]
        let traktorVersions = TraktorVersions(
            versions: versions,
            selectedVersionId: nil
        )
        
        // When
        let selectedVersion = traktorVersions.selectedVersion
        
        // Then - should return latest version (max)
        #expect(selectedVersion?.version == "4.2.0")
        #expect(selectedVersion?.folderName == "Traktor 4.2.0")
    }
    
    @Test func traktorVersionsSelectedVersionWithEmptyArray() {
        // Given
        let traktorVersions = TraktorVersions(
            versions: [],
            selectedVersionId: nil
        )
        
        // When
        let selectedVersion = traktorVersions.selectedVersion
        
        // Then
        #expect(selectedVersion == nil)
    }
    
    @Test func traktorVersionsSelectedVersionWithInvalidSelectedId() {
        // Given
        let versions = [
            TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1"),
            TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0")
        ]
        let traktorVersions = TraktorVersions(
            versions: versions,
            selectedVersionId: "Traktor 5.0.0" // Non-existent ID
        )
        
        // When
        let selectedVersion = traktorVersions.selectedVersion
        
        // Then - should fall back to max version
        #expect(selectedVersion?.version == "4.2.0")
    }
    
    @Test func traktorVersionsEncodesAndDecodes() throws {
        // Given
        let versions = [
            TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1", isSelected: true),
            TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0", isSelected: false)
        ]
        let originalTraktorVersions = TraktorVersions(
            versions: versions,
            selectedVersionId: "Traktor 4.1.1"
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTraktorVersions)
        
        let decoder = JSONDecoder()
        let decodedTraktorVersions = try decoder.decode(TraktorVersions.self, from: data)
        
        // Then
        #expect(decodedTraktorVersions.versions.count == originalTraktorVersions.versions.count)
        #expect(decodedTraktorVersions.selectedVersionId == originalTraktorVersions.selectedVersionId)
        #expect(decodedTraktorVersions.versions[0].version == "4.1.1")
        #expect(decodedTraktorVersions.versions[1].version == "4.2.0")
    }
    
    // MARK: - Identifiable Tests
    
    @Test func traktorVersionIsIdentifiable() {
        // Given
        let version1 = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1")
        let version2 = TraktorVersion(version: "4.1.1", folderName: "Traktor 4.1.1")
        let version3 = TraktorVersion(version: "4.2.0", folderName: "Traktor 4.2.0")
        
        // Then
        #expect(version1.id == version2.id) // Same folder name = same ID
        #expect(version1.id != version3.id) // Different folder name = different ID
    }
}
