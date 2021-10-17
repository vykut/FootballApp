//
//  LocalStorageService.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import CoreData
import Combine
import os

class LocalStorageService: LocalStorageServiceProtocol {
    static let shared: LocalStorageService = .init()

    private let context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    private let logger: Logger = .init(subsystem: "Football App", category: "Local Storage")

    /// this publisher will be used to notify the subscribers that there has been a data change for the favourite players database
    /// ideally, the database itself can be refactored to be Combine-friendly
    /// because of time constraints this approach has been used instead
    private var favouritePlayersDidChange: CurrentValueSubject<Void, Never> = .init(())

    private var subscriptions: Set<AnyCancellable> = []

    private init() { }

    func removePlayerFromFavourites(_ player: Player) {
        searchForPlayers(id: player.id)
            .first()
            .sink { [weak self] players in
                players.forEach { self?.context.delete($0) }
                self?.save()
            }
            .store(in: &subscriptions)
    }

    func addPlayerToFavourites(_ player: Player) {
        searchForPlayers(id: player.id)
            .first()
            .map(\.first)
            .sink { [weak self] value in
                if let favouritePlayer = value {
                    favouritePlayer.firstName = player.firstName
                    favouritePlayer.secondName = player.secondName
                    favouritePlayer.nationality = player.nationality
                    favouritePlayer.age = player.age
                    favouritePlayer.club = player.club
                } else if let context = self?.context {
                    let favouritePlayer: FavouritePlayer = .init(context: context)
                    favouritePlayer.id = player.id
                    favouritePlayer.firstName = player.firstName
                    favouritePlayer.secondName = player.secondName
                    favouritePlayer.nationality = player.nationality
                    favouritePlayer.age = player.age
                    favouritePlayer.club = player.club
                }

                self?.save()
            }
            .store(in: &subscriptions)
    }

    private func searchForPlayers(id: Player.ID) -> AnyPublisher<[FavouritePlayer], Never> {
        favouritePlayersDidChange
            .compactMap { [weak context] _ -> [FavouritePlayer]? in
                let fetchRequest: NSFetchRequest<FavouritePlayer> = FavouritePlayer.fetchRequest()
                fetchRequest.predicate = .init(format: "id = %@", id)
                return try? context?.fetch(fetchRequest)
            }
            .eraseToAnyPublisher()
    }

    @discardableResult
    private func save() -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            favouritePlayersDidChange.send()
            return true
        } catch {
            logger.error("Could not save database.\nError: \(error.localizedDescription)")
            return false
        }
    }

    func getAllFavouritePlayers() -> AnyPublisher<[FavouritePlayer], Never> {
        favouritePlayersDidChange
            .compactMap { [weak context] _ -> [FavouritePlayer]? in
                let fetchRequest: NSFetchRequest<FavouritePlayer> = FavouritePlayer.fetchRequest()
                fetchRequest.sortDescriptors = [
                    .init(keyPath: \FavouritePlayer.firstName, ascending: true)
                ]
                return try? context?.fetch(fetchRequest)
            }
            .eraseToAnyPublisher()
    }

    func lookupFavouritePlayers(_ lookup: String) -> AnyPublisher<[FavouritePlayer], Never> {
        favouritePlayersDidChange
            .compactMap { [weak context] _ -> [FavouritePlayer]? in
                let fetchRequest: NSFetchRequest<FavouritePlayer> = FavouritePlayer.fetchRequest()
                let predicate: NSCompoundPredicate = .init(orPredicateWithSubpredicates: [
                    NSPredicate(format: "firstName CONTAINS[c] %@", lookup),
                    NSPredicate(format: "secondName CONTAINS[c] %@", lookup)
                ])
                fetchRequest.predicate = predicate
                return try? context?.fetch(fetchRequest)
            }
            .eraseToAnyPublisher()
    }
}
