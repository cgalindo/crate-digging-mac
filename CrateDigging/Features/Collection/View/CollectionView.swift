//
//  CollectionView.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import SwiftUI

struct CollectionView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading collection...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let data):
                VStack {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Collection")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text("Your music collection will appear here")
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
    CollectionView()
}
