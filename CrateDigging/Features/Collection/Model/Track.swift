//
//  Track.swift
//  CrateDigging
//
//  Created by Chris Galindo on 9/13/25.
//

import Foundation

// MARK: - Track Model
struct Track: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let bpm: Int
    let genre: String
    let imageName: String? // For now using system image names, later can be URLs or asset names
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Sample Data
extension Track {
    static let sampleTracks: [Track] = [
        Track(
            title: "Midnight Dreams",
            artist: "Electronic Vibes",
            bpm: 128,
            genre: "House",
            imageName: "music.note"
        ),
        Track(
            title: "Sunrise Boulevard",
            artist: "Jazz Collective",
            bpm: 95,
            genre: "Jazz",
            imageName: "music.note"
        ),
        Track(
            title: "Digital Horizon",
            artist: "Synth Masters",
            bpm: 140,
            genre: "Techno",
            imageName: "music.note"
        ),
        Track(
            title: "Ocean Waves",
            artist: "Ambient Sounds",
            bpm: 72,
            genre: "Ambient",
            imageName: "music.note"
        ),
        Track(
            title: "City Lights",
            artist: "Urban Beat",
            bpm: 110,
            genre: "Hip Hop",
            imageName: "music.note"
        ),
        Track(
            title: "Mountain Echo",
            artist: "Folk Journey",
            bpm: 88,
            genre: "Folk",
            imageName: "music.note"
        ),
        
        // Row 2
        Track(
            title: "Neon Nights",
            artist: "Retro Wave",
            bpm: 126,
            genre: "Synthwave",
            imageName: "music.note"
        ),
        Track(
            title: "Thunder Storm",
            artist: "Rock Legends",
            bpm: 145,
            genre: "Rock",
            imageName: "music.note"
        ),
        Track(
            title: "Smooth Operator",
            artist: "R&B Kings",
            bpm: 92,
            genre: "R&B",
            imageName: "music.note"
        ),
        Track(
            title: "Bass Drop",
            artist: "EDM Masters",
            bpm: 150,
            genre: "Dubstep",
            imageName: "music.note"
        ),
        Track(
            title: "Acoustic Dreams",
            artist: "Indie Folk",
            bpm: 76,
            genre: "Indie",
            imageName: "music.note"
        ),
        Track(
            title: "Latin Fire",
            artist: "Salsa Unidos",
            bpm: 180,
            genre: "Latin",
            imageName: "music.note"
        ),
        
        // Row 3
        Track(
            title: "Deep Space",
            artist: "Cosmic Sounds",
            bpm: 120,
            genre: "Trance",
            imageName: "music.note"
        ),
        Track(
            title: "Country Road",
            artist: "Nashville Stars",
            bpm: 120,
            genre: "Country",
            imageName: "music.note"
        ),
        Track(
            title: "Funky Town",
            artist: "Groove Machine",
            bpm: 108,
            genre: "Funk",
            imageName: "music.note"
        ),
        Track(
            title: "Classical Sunrise",
            artist: "Orchestra Divine",
            bpm: 60,
            genre: "Classical",
            imageName: "music.note"
        ),
        Track(
            title: "Reggae Vibes",
            artist: "Island Rhythm",
            bpm: 85,
            genre: "Reggae",
            imageName: "music.note"
        ),
        Track(
            title: "Metal Storm",
            artist: "Heavy Thunder",
            bpm: 160,
            genre: "Metal",
            imageName: "music.note"
        ),
        
        // Row 4
        Track(
            title: "Disco Fever",
            artist: "Retro Funk",
            bpm: 118,
            genre: "Disco",
            imageName: "music.note"
        ),
        Track(
            title: "Minimal Beats",
            artist: "Tech Underground",
            bpm: 132,
            genre: "Minimal",
            imageName: "music.note"
        ),
        Track(
            title: "Gospel Truth",
            artist: "Sacred Voices",
            bpm: 72,
            genre: "Gospel",
            imageName: "music.note"
        ),
        Track(
            title: "Punk Energy",
            artist: "Rebel Youth",
            bpm: 180,
            genre: "Punk",
            imageName: "music.note"
        ),
        Track(
            title: "Chill Waves",
            artist: "Lo-Fi Collective",
            bpm: 85,
            genre: "Lo-Fi",
            imageName: "music.note"
        ),
        Track(
            title: "Progressive Journey",
            artist: "Sonic Explorers",
            bpm: 138,
            genre: "Progressive",
            imageName: "music.note"
        ),
        
        // Row 5
        Track(
            title: "Trap Nation",
            artist: "Street Beats",
            bpm: 140,
            genre: "Trap",
            imageName: "music.note"
        ),
        Track(
            title: "Blues Highway",
            artist: "Delta Kings",
            bpm: 75,
            genre: "Blues",
            imageName: "music.note"
        ),
        Track(
            title: "World Fusion",
            artist: "Global Sounds",
            bpm: 110,
            genre: "World",
            imageName: "music.note"
        ),
        Track(
            title: "Experimental Lab",
            artist: "Sound Scientists",
            bpm: 95,
            genre: "Experimental",
            imageName: "music.note"
        ),
        Track(
            title: "Swing Time",
            artist: "Big Band Era",
            bpm: 130,
            genre: "Swing",
            imageName: "music.note"
        ),
        Track(
            title: "Psychedelic Trip",
            artist: "Mind Benders",
            bpm: 115,
            genre: "Psychedelic",
            imageName: "music.note"
        ),
        
        // Row 6
        Track(
            title: "Hardstyle Anthem",
            artist: "Rave Masters",
            bpm: 150,
            genre: "Hardstyle",
            imageName: "music.note"
        ),
        Track(
            title: "Bossa Nova",
            artist: "Brazilian Smooth",
            bpm: 120,
            genre: "Bossa Nova",
            imageName: "music.note"
        ),
        Track(
            title: "Garage Vibes",
            artist: "Underground UK",
            bpm: 130,
            genre: "UK Garage",
            imageName: "music.note"
        ),
        Track(
            title: "Drum & Bass",
            artist: "Liquid Motion",
            bpm: 174,
            genre: "DnB",
            imageName: "music.note"
        ),
        Track(
            title: "Afrobeat Rhythm",
            artist: "African Pulse",
            bpm: 125,
            genre: "Afrobeat",
            imageName: "music.note"
        ),
        Track(
            title: "Future Bass",
            artist: "Digital Dreams",
            bpm: 140,
            genre: "Future Bass",
            imageName: "music.note"
        )
    ]
}

