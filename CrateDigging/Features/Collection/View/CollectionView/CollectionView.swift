//
//  CollectionView.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import SwiftUI

struct CollectionView: View {
    @State private var viewModel = ViewModel()
    let filterOptions: FilterOptions
    
    init(filterOptions: FilterOptions = FilterOptions()) {
        self.filterOptions = filterOptions
    }
    
    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                AdaptiveProgressView(message: "Loading collection...")
            case .loaded(let tracks):
                mainContent(tracks)
            case .error(let error):
                errorView(error: error)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Helper Methods
extension CollectionView {
    // TODO: Refactor to work with error view
    private var emptyCollectionView: some View {
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
    }
    
    // TODO: Refactor to work with error view
    private var noResultsView: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Results")
                .font(.title2)
                .fontWeight(.medium)
            Text("No tracks match your current filters")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    private func mainContent(_ tracks: [Track]) -> some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: viewModel.cardSpacing),
                        count: viewModel.columnCount(for: geometry.size.width)
                    ),
                    spacing: viewModel.cardSpacing
                ) {
                    ForEach(tracks) { track in
                        TrackCardView(track: track)
                            .frame(
                                width: viewModel.adaptiveCardWidth(for: geometry.size.width),
                                height: viewModel.adaptiveCardHeight(for: geometry.size.width)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
            }
            .frame(minWidth: viewModel.minWindowWidth)
        }
    }
    
    private func errorView(error: DisplayableError) -> some View {
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

#Preview {
    CollectionView()
}
