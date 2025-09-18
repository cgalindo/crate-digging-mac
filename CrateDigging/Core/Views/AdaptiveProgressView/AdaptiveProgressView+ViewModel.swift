//
//  AdaptiveProgressView+ViewModel.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/18/25.
//

import Foundation

extension AdaptiveProgressView {
    
    @Observable
    @MainActor
    final class ViewModel {
        
        // MARK: - Constants
        let progressScale: CGFloat = 2.0
        let progressSizeRatio: CGFloat = 0.25 // 1/4 of screen width
        
        init() {}
        
        // MARK: - Helper Methods
        func progressSize(for width: CGFloat) -> CGFloat {
            return width * progressSizeRatio
        }
    }
}
