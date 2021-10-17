//
//  Persistence.swift
//  Football
//
//  Created by vsocaciu on 17.10.2021.
//

import CoreData
import os

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    let logger: Logger = Logger(subsystem: "Football App", category: "Core Data")

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Football")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        loadContainer()
    }

    private func loadContainer() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                self.logger.error("Core Data Container could not be initialised: \(error.localizedDescription)")
            } else {
                self.logger.debug("Core Data Container successfully loaded")
            }
        }
    }
}
