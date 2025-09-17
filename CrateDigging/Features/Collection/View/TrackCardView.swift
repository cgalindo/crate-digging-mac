//
//  TrackCardView.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import SwiftUI

struct TrackCardView: View {
    let track: Track
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Track image at the top
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.systemGray))
                    .aspectRatio(1, contentMode: .fit)
                
                if let imageName = track.imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                }
            }
            
            // Track info underneath
            VStack(alignment: .center, spacing: 4) {
                // Line 1: Track title
                Text(track.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Line 2: Track artist
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Line 3: BPM and Genre
                HStack(spacing: 8) {
                    Text("\(track.bpm) BPM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(track.genre)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    LazyVGrid(
        columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ],
        spacing: 16
    ) {
        ForEach(Array(Track.sampleTracks.prefix(6))) { track in
            TrackCardView(track: track)
        }
    }
    .padding()
}
