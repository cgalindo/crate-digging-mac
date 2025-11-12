//
//  FolderSetting.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

struct FolderSetting: Identifiable {
    let title: String
    let panelItem: TraktorPanelItem
    var path: String?
    
    var id: String {
        title
    }
    
    init(
        title: String,
        path: String? = nil,
        panelItem: TraktorPanelItem
    ) {
        self.title = title
        self.path = path
        self.panelItem = panelItem
    }
}

