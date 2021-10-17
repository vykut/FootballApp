//
//  FootballAppApp.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import SwiftUI

@main
struct FootballAppApp: App {
    let persistenceController: PersistenceController = .shared

    var body: some Scene {
        WindowGroup {
            PlayersAndTeamsNavigation()
            // inject the Core Data context into the View hierarchy
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
