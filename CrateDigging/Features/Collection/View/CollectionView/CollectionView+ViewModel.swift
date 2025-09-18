//
//  CollectionView+ViewModel.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

extension CollectionView {
    
    @Observable
    @MainActor
    final class ViewModel {
        var state: ViewState<[Track]> = .loading
        
        // MARK: - Constants
        let minCardWidth: CGFloat = 160
        let minCardHeight: CGFloat = 224
        let cardSpacing: CGFloat = 16
        let maxColumns: Int = 6
        let minColumns: Int = 4
        let minWindowWidth: CGFloat = 704
        
        init() {
            state = .loading
        }
        
        func loadData() async {
            // Simulate loading delay
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // For now, return sample track data
            let tracks = Track.sampleTracks
            state = .loaded(tracks)
        }
        
        // MARK: - Helper Methods
        func columnCount(for width: CGFloat) -> Int {
            let availableWidth = width - 64 // Account for horizontal padding (32px on each side)
            let minCardWithSpacing = minCardWidth + cardSpacing
            let calculatedColumns = Int(availableWidth / minCardWithSpacing)
            return max(minColumns, min(maxColumns, calculatedColumns))
        }
        
        func adaptiveCardWidth(for width: CGFloat) -> CGFloat {
            let columns = columnCount(for: width)
            let availableWidth = width - 64 // Account for horizontal padding (32px on each side)
            let totalSpacing = CGFloat(columns - 1) * cardSpacing
            let cardWidth = (availableWidth - totalSpacing) / CGFloat(columns)
            return max(minCardWidth, cardWidth)
        }
        
        func adaptiveCardHeight(for width: CGFloat) -> CGFloat {
            let cardWidth = adaptiveCardWidth(for: width)
            let aspectRatio = minCardHeight / minCardWidth
            return cardWidth * aspectRatio
        }
    }
    
}

