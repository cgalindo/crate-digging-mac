//
//  CratesView.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import SwiftUI

struct CratesView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                AdaptiveProgressView(message: "Loading crates...")
            case .loaded(let data):
                VStack {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Crates")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text("Your crates will appear here")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let error):
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text(error.localizedDescription)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    CratesView()
}
