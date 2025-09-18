//
//  HomeView+ViewModel.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

extension HomeView {
    
    @Observable
    @MainActor
    final class ViewModel {
        var selectedItem: MenuItem = .collection
        
        init() {
            // Collection is the default selected item
            selectedItem = .collection
        }
    }
    
}
