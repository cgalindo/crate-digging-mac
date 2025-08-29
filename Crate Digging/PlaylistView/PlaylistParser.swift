//
//  PlaylistParser.swift
//  Crate Digging
//
//  Created by Chris Galindo on 6/5/25.
//

import Foundation

struct PlaylistParser {
    
    func parse(for  fileURL: URL) throws -> Playlist {
        let fileURLString = fileURL.absoluteString
        
        let fileComponents = fileURLString.components(separatedBy: "/")
        guard let fileNameComponents = fileComponents.last?.components(separatedBy: "_"),
              fileNameComponents.count == 3
        else {
            throw ParseError.badFileFormat
        }
        
        let date = configureDate(components: fileNameComponents)
        let playlist = Playlist(date: date)
        
        guard let playlistData = try? Data(contentsOf: fileURL) else {
            throw ParseError.badData
        }
        
        let parser = XMLParser(data: playlistData)
        let delegate = PlaylistXMLParserDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            throw ParseError.parsingFailed
        }
        
        return playlist
    }
    
    private func configureDate(components fileNameComponents: [String]) -> Date {
        let dateComponent = fileNameComponents[1]
        let year = dateComponent.prefix(4)
        let month = dateComponent.dropFirst(5).dropLast(4)
        let day = dateComponent.dropFirst(8).dropLast()
        let date = "\(month)-\(day)-\(year)"
        
        let timeComponent = fileNameComponents[2].dropLast(4)
        let hour = timeComponent.prefix(2)
        let minutes = timeComponent.dropFirst(3).dropLast(4)
        let time = "\(hour):\(minutes)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        // TODO: Need to consider if Date cannot be created.
        return dateFormatter.date(from: "\(date) \(time)") ?? Date()
    }
}

extension PlaylistParser {
    
    enum ParseError: Error {
        /// File format is not correct to extract date
        case badFileFormat
        
        /// Could not convert file to Data type
        case badData
        
        /// Could not parse the file
        case parsingFailed
    }
}
