//
//  PlaylistXMLParserDelegate.swift
//  Crate Digging
//
//  Created by Chris Galindo on 6/5/25.
//

import Foundation

final class PlaylistXMLParserDelegate: NSObject, XMLParserDelegate {
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        print("Started element: \(elementName)")
        
        if attributeDict.count > 0 {
            for (key, value) in attributeDict {
                print("\tAttribute: \(key): \(value)")
            }
        }
    }
    
}
