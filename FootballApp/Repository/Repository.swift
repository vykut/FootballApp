//
//  Repository.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation
import Combine

enum RepositoryError: Error {
    case playersAndTeamsService(PlayersAndTeamsServiceError)
    case error(Error)
}

/// The Repository layer provides a way of abstracting the data model in a way that the consumers will not be aware, nor care whether the data comes from the backend, from local storage or from runtime
class Repository: RepositoryProtocol {
    static let shared: Repository = .init()

    private let playersAndTeamsService: PlayersAndTeamsServiceProtocol
    private let localStorageService: LocalStorageServiceProtocol

    /// inject dependencies through the initialiser
    /// these dependencies can be mocked for unit testing purposes
    private init(
        playersAndTeamsService: PlayersAndTeamsServiceProtocol = PlayersAndTeamsService.shared,
        localStorageService: LocalStorageServiceProtocol = LocalStorageService.shared
    ) {
        self.playersAndTeamsService = playersAndTeamsService
        self.localStorageService = localStorageService
    }
}

// MARK: - Players And Teams Service
extension Repository {
    func getPlayersAndTeams(searchText: String) -> AnyPublisher<PlayersAndTeams, RepositoryError> {
        let request: PlayersAndTeamsRequest = .init(
            searchString: searchText,
            searchType: nil,
            offset: nil,
            requestOrder: nil
        )

        return fetchPlayersAndTeams(request: request)
    }

    func getPlayers(searchText: String, offset: Int) -> AnyPublisher<[Player], RepositoryError> {
        let request: PlayersAndTeamsRequest = .init(
            searchString: searchText,
            searchType: .players,
            offset: offset,
            requestOrder: nil
        )

        return fetchPlayersAndTeams(request: request)
            .map(\.players)
            .eraseToAnyPublisher()
    }

    func getTeams(searchText: String, offset: Int) -> AnyPublisher<[Team], RepositoryError> {
        let request: PlayersAndTeamsRequest = .init(
            searchString: searchText,
            searchType: .teams,
            offset: offset,
            requestOrder: nil
        )

        return fetchPlayersAndTeams(request: request)
            .map(\.teams)
            .eraseToAnyPublisher()
    }
}

// MARK: - Local Storage Service
extension Repository {
    func addPlayerToFavourites(_ player: Player) {
        localStorageService.addPlayerToFavourites(player)
    }

    func removePlayerFromFavourites(_ player: Player) {
        localStorageService.removePlayerFromFavourites(player)
    }

    func getAllFavouritePlayers() -> AnyPublisher<[Player], Never> {
        localStorageService.getAllFavouritePlayers()
            /// map `FavouritePlayer` objects to `Player` objects
            .map { favouritePlayers in
                favouritePlayers.compactMap { favouritePlayer -> Player? in
                    guard let id = favouritePlayer.id,
                          let firstName = favouritePlayer.firstName,
                          let secondName = favouritePlayer.secondName,
                          let nationality = favouritePlayer.nationality,
                          let age = favouritePlayer.age,
                          let club = favouritePlayer.club else { return nil }

                    return Player(
                        id: id,
                        firstName: firstName,
                        secondName: secondName,
                        nationality: nationality,
                        age: age,
                        club: club
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func getFavouritePlayersIDs(lookup: String) -> AnyPublisher<Set<Player.ID>, Never> {
        guard !lookup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Just([])
                .eraseToAnyPublisher()
        }

        return localStorageService.lookupFavouritePlayers(lookup)
            .map { favouritePlayers -> [Player.ID] in
                favouritePlayers.compactMap(\.id)
            }
            .map(Set.init)
            .subscribe(on: Threads.localStorageServiceThread)
            .eraseToAnyPublisher()
    }

    private func fetchPlayersAndTeams(request: PlayersAndTeamsRequest) -> AnyPublisher<PlayersAndTeams, RepositoryError> {
        playersAndTeamsService.fetchPlayersAndTeams(body: request)
            .map(\.result)
            .mapError { .playersAndTeamsService($0) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Flags
extension Repository {
    func getFlags() -> AnyPublisher<[String : String], RepositoryError> {
        Just("Flags")
            .compactMap { fileName in
                Bundle.main.url(forResource: fileName, withExtension: "json")
            }
            .tryMap { url in
                try Data(contentsOf: url)
            }
            .tryMap { data in
                try JSONDecoder().decode([Flag].self, from: data)
            }
            .mapError { .error($0) }
            .map { flags in
                flags.reduce(into: [String: String]()) { accumulator, flag in
                    accumulator[flag.name] = flag.emoji
                }
            }
            .subscribe(on: Threads.flagsThread)
            .eraseToAnyPublisher()
    }
}

// a Mock object to be used for unit testing
extension Repository {
    static func getMockRepository(
        playersAndTeamsService: PlayersAndTeamsServiceProtocol,
        localStorageService: LocalStorageServiceProtocol
    ) -> Repository {
        .init(
            playersAndTeamsService: playersAndTeamsService,
            localStorageService: localStorageService
        )
    }
}
