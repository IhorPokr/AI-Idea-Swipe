//
//  AI_Idea_SwipeApp.swift
//  AI Idea Swipe
//
//  Created by Ihor Pokrovetskyi on 2/21/25.
//

import SwiftUI
import SwiftData

@main
struct AI_Idea_SwipeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
