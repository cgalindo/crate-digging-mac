//
//  PlaylistView+ViewModel.swift
//  Crate Digging
//
//  Created by Chris Galindo on 6/4/25.
//

import Foundation
import AppKit

extension PlaylistView {
    
    /// View State for playlist view
    enum state {
        case noPlaylists
        case playlist(Playlist)
    }
    
    @Observable
    final class ViewModel {
        
        var state: state = .noPlaylists
        private var playlistParser = PlaylistParser()
        
        func displayFileChooser() {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            
            guard panel.runModal() == .OK,
                  let fileURL = panel.url else { return }
                  
            do {
                let playlist = try playlistParser.parse(for: fileURL)
                state = .playlist(playlist)
            } catch {
                displayError()
            }
        }
        
        private func displayError() {
            let alert = NSAlert()
            alert.messageText = "File Error"
            alert.informativeText = "There was an issue opening the file. Please try again."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        
//        func historyFolderFound() -> Bool {
//            var isDirectory: ObjCBool = true
//            
//            let manager = FileManager.default
//            let urls = manager.urls(for: .downloadsDirectory, in: .userDomainMask)
//            guard let documentDirectoryUrl = urls.first else {
//                return false
//            }
//            let historyFolderUrl = documentDirectoryUrl.appendingPathComponent("Native%20Instruments/Traktor%204.1.1/History")
//            
//            var isStale: Bool = false
//            let test = try? URL(resolvingBookmarkData: <#T##Data#>, options: <#T##URL.BookmarkResolutionOptions#>, bookmarkDataIsStale: &isStale)
//            return manager.fileExists(atPath: historyFolderUrl.path, isDirectory: &isDirectory)
//        }
    }
}
