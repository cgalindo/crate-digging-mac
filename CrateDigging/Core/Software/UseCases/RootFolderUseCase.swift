//
//  RootFolderUseCase.swift
//  CrateDigging
//
//  Created by Chris Galindo on 11/4/25.
//

import Foundation

protocol RootFolderUseCase: Sendable {
    /// Processes the root folder to find versions and bookmark history/collection paths
    /// - Parameter rootFolderURL: The URL of the selected root folder
    func callAsFunction(_ rootFolderURL: URL) async throws
}
