//
//  PanelItem.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 10/21/25.
//

import Foundation

public protocol PanelItem: Sendable {
    var title: String { get }
    var message: String { get }
    var prompt: String { get }
    var directoryURL: URL? { get }
    var canChooseDirectories: Bool { get }
    var canChooseFiles: Bool { get }
    var allowsMultipleSelection: Bool { get }
    var cancreateDirectories: Bool { get }
    var storeKey: String { get }
}
