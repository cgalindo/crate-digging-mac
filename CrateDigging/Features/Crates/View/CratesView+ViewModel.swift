//
//  CratesView+ViewModel.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

extension CratesView {
    
    @Observable
    @MainActor
    final class ViewModel {
        var state: ViewState<CratesMenuItem> = .loading
        
        init() {
            state = .loading
        }
        
        func loadData() async {
            // Simulate loading delay
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // For now, return mock data
            let mockData = CratesMenuItem()
            state = .loaded(mockData)
        }
    }
    
}

