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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                switch viewModel.state {
                case .loading:
                    AdaptiveProgressView(message: "Loading collection...")
                case .loaded(let tracks):
                    if tracks.isEmpty {
                        emptyCollectionView
                    } else {
                        mainContent(tracks)
                    }
                case .error(let error):
                    errorView(error: error)
                }
                
                topBar
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Helper Methods
extension CollectionView {
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
    
    @ViewBuilder
    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // Filter button
                    Button(action: {
                        // TODO: Implement filter functionality
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .help("Filter tracks")
                    
                    // Search button
                    Button(action: {
                        // TODO: Implement search functionality
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .help("Search tracks")
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(.thinMaterial)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(NSColor.separatorColor).opacity(0.6)),
                alignment: .bottom
            )
            
            Spacer()
        }
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
                            .frame(width: viewModel.adaptiveCardWidth(for: geometry.size.width), height: viewModel.adaptiveCardHeight(for: geometry.size.width))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 64)
                .padding(.bottom, 24)
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
