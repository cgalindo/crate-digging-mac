//
//  AdaptiveProgressView.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/18/25.
//

import SwiftUI

struct AdaptiveProgressView: View {
    @State private var viewModel = ViewModel()
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                ProgressView(message)
                    .scaleEffect(viewModel.progressScale)
                    .frame(width: viewModel.progressSize(for: geometry.size.width), 
                           height: viewModel.progressSize(for: geometry.size.width))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    AdaptiveProgressView(message: "Loading collection...")
        .frame(width: 800, height: 600)
}
