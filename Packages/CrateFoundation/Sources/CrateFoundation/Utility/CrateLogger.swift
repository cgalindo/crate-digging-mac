//
//  CrateLogger.swift
//  CrateFoundation
//
//  Created by Chris Galindo on 10/18/25.
//

import Foundation
import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static let subsystem = Bundle.main.bundleIdentifier!

    /// Logs an event in Folder Management logic.
    static let folderManagement = Logger(subsystem: subsystem, category: "folder-management")
}
