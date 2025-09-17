//
//  CrateDiggingApp.swift
//  Crate Digging
//
//  Created by Chris Galindo on 6/4/25.
//

import SwiftUI
import SwiftData

@main
struct CrateDiggingApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 864, height: 600)
//        .modelContainer(sharedModelContainer)
    }
}
