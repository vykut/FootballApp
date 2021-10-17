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

protocol RepositoryProtocol {
    func getPlayersAndTeams(searchText: String) -> AnyPublisher<PlayersAndTeams, RepositoryError>
    func getPlayers(searchText: String, offset: Int) -> AnyPublisher<[Player], RepositoryError>
    func getTeams(searchText: String, offset: Int) -> AnyPublisher<[Team], RepositoryError>

    @discardableResult func addPlayerToFavourites(_ player: Player) -> Bool
    @discardableResult func removePlayerFromFavourites(_ player: Player) -> Bool
    @discardableResult func removePlayersFromFavourites(_ players: [FavouritePlayer]) -> Bool
    func getFavouritePlayersIDs(lookup: String) -> AnyPublisher<Set<Player.ID>, Never>

    func getFlags() -> AnyPublisher<[String: String], RepositoryError>
}

class Repository: RepositoryProtocol {
    static let shared: Repository = .init()

    private let playersAndTeamsService: PlayersAndTeamsServiceProtocol
    private let localStorage: LocalStorageServiceProtocol

    private init(
        playersAndTeamsService: PlayersAndTeamsServiceProtocol = PlayersAndTeamsService.shared,
        localStorage: LocalStorageServiceProtocol = LocalStorageService.shared
    ) {
        self.playersAndTeamsService = playersAndTeamsService
        self.localStorage = localStorage
    }

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

    @discardableResult
    func addPlayerToFavourites(_ player: Player) -> Bool {
        let success = localStorage.addPlayerToFavourites(player)
        if success {
            favouritePlayersDidChange.send()
        }
        return success
    }

    @discardableResult
    func removePlayerFromFavourites(_ player: Player) -> Bool {
        let success = localStorage.removePlayerFromFavourites(player)
        if success {
            favouritePlayersDidChange.send()
        }
        return success
    }

    @discardableResult
    func removePlayersFromFavourites(_ players: [FavouritePlayer]) -> Bool {
        let success = localStorage.removePlayersFromFavourites(players)
        if success {
            favouritePlayersDidChange.send()
        }
        return success
    }

    private var favouritePlayersDidChange: CurrentValueSubject<Void, Never> = .init(())

    func getFavouritePlayersIDs(lookup: String) -> AnyPublisher<Set<Player.ID>, Never> {
        favouritePlayersDidChange
            .compactMap { [weak self] _ -> [FavouritePlayer]? in
                self?.localStorage.lookupFavouritePlayers(lookup)
            }
            .map { favouritePlayers -> [Player.ID] in
                favouritePlayers.compactMap(\.id)
            }
            .map(Set.init)
            .eraseToAnyPublisher()
    }

    private func fetchPlayersAndTeams(request: PlayersAndTeamsRequest) -> AnyPublisher<PlayersAndTeams, RepositoryError> {
        playersAndTeamsService.fetchPlayersAndTeams(body: request)
            .map(\.result)
            .mapError { .playersAndTeamsService($0) }
            .eraseToAnyPublisher()
    }

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
