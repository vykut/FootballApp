//
//  LocalStorageService.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import CoreData
import os

protocol LocalStorageServiceProtocol {
    @discardableResult func addPlayerToFavourites(_ player: Player) -> Bool
    @discardableResult func removePlayerFromFavourites(_ player: Player) -> Bool
    @discardableResult func removePlayersFromFavourites(_ players: [FavouritePlayer]) -> Bool
    func lookupFavouritePlayers(_ lookup: String) -> [FavouritePlayer]?
}

class LocalStorageService: LocalStorageServiceProtocol {
    static let shared: LocalStorageService = .init()

    private let context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    private let logger: Logger = .init(subsystem: "Football App", category: "Local Storage")

    private init() { }

    @discardableResult
    func removePlayersFromFavourites(_ players: [FavouritePlayer]) -> Bool {
        players.forEach(context.delete)

        return save()
    }

    @discardableResult
    func removePlayerFromFavourites(_ player: Player) -> Bool {
        if let favouritePlayers = searchForPlayers(id: player.id) {
            favouritePlayers.forEach(context.delete)
            return save()
        }
        return false
    }

    @discardableResult
    func addPlayerToFavourites(_ player: Player) -> Bool {
        if let favouritePlayer = searchForPlayers(id: player.id)?.first {
            favouritePlayer.firstName = player.firstName
            favouritePlayer.secondName = player.secondName
            favouritePlayer.nationality = player.nationality
            favouritePlayer.age = player.age
            favouritePlayer.club = player.club
        } else {
            let favouritePlayer: FavouritePlayer = .init(context: context)
            favouritePlayer.id = player.id
            favouritePlayer.firstName = player.firstName
            favouritePlayer.secondName = player.secondName
            favouritePlayer.nationality = player.nationality
            favouritePlayer.age = player.age
            favouritePlayer.club = player.club
        }

        return save()
    }

    private func searchForPlayers(id: Player.ID) -> [FavouritePlayer]? {
        let fetchRequest: NSFetchRequest<FavouritePlayer> = FavouritePlayer.fetchRequest()
        fetchRequest.predicate = .init(format: "id = %@", id)
        return try? context.fetch(fetchRequest)
    }

    private func save() -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            return true
        } catch {
            logger.error("Could not save database.\nError: \(error.localizedDescription)")
            return false
        }
    }

    func lookupFavouritePlayers(_ lookup: String) -> [FavouritePlayer]? {
        let fetchRequest: NSFetchRequest<FavouritePlayer> = FavouritePlayer.fetchRequest()
        let predicate: NSCompoundPredicate = .init(orPredicateWithSubpredicates: [
            NSPredicate(format: "firstName CONTAINS[c] %@", lookup),
            NSPredicate(format: "secondName CONTAINS[c] %@", lookup)
        ])
        fetchRequest.predicate = predicate
        return try? context.fetch(fetchRequest)
    }
}
