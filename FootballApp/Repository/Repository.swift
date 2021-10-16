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

    func getFavouritePlayersIDs() -> AnyPublisher<Set<Player.ID>, RepositoryError>
    @discardableResult func addPlayerToFavourites(_ player: Player) -> Bool
    @discardableResult func removePlayerFromFavourites(_ player: Player) -> Bool

    func getFlags() -> AnyPublisher<[String: URL], RepositoryError>
}

class Repository: RepositoryProtocol {
    static let shared: Repository = .init()

    private let playersAndTeamsService: PlayersAndTeamsServiceProtocol

    private init(playersAndTeamsService: PlayersAndTeamsServiceProtocol = PlayersAndTeamsService.shared) {
        self.playersAndTeamsService = playersAndTeamsService
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

    func getFavouritePlayersIDs() -> AnyPublisher<Set<Player.ID>, RepositoryError> {
        favouritePlayersIDs
            .setFailureType(to: RepositoryError.self)
            .eraseToAnyPublisher()
    }

    private let favouritePlayersIDs: CurrentValueSubject<Set<Player.ID>, Never> = .init([])

    @discardableResult
    func addPlayerToFavourites(_ player: Player) -> Bool {
        favouritePlayersIDs.value.insert(player.id).inserted
    }

    @discardableResult
    func removePlayerFromFavourites(_ player: Player) -> Bool {
        favouritePlayersIDs.value.remove(player.id) != nil
    }

    private func fetchPlayersAndTeams(request: PlayersAndTeamsRequest) -> AnyPublisher<PlayersAndTeams, RepositoryError> {
        playersAndTeamsService.fetchPlayersAndTeams(body: request)
            .map(\.result)
            .mapError { .playersAndTeamsService($0) }
            .eraseToAnyPublisher()
    }

    func getFlags() -> AnyPublisher<[String : URL], RepositoryError> {
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
                flags.reduce(into: [String: URL]()) { accumulator, flag in
                    accumulator[flag.name] = flag.image
                }
            }
            .subscribe(on: Threads.flagsThread)
            .eraseToAnyPublisher()
    }
}
