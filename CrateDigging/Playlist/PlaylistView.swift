//
//  PlaylistView.swift
//  Crate Digging
//
//  Created by Chris Galindo on 6/4/25.
//

import SwiftUI

struct PlaylistView: View {
    @State var viewmodel: ViewModel = ViewModel()
    
    var body: some View {
        switch viewmodel.state {
        case .noPlaylists:
            selectFileView
        case .playlist(let playlist):
            foundPlaylistView(playlist: playlist)
        }
    }
    
    var selectFileView: some View {
        HStack {
            Text("Select NML file")
            Button("select File")
            {
                viewmodel.displayFileChooser()
            }
        }
        .padding()
    }
    
    func foundPlaylistView(playlist: Playlist) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Date: ")
                Text(playlist.date.formatted(date: .numeric, time: .shortened))
            }
        }
    }
}

#Preview {
    PlaylistView()
}
