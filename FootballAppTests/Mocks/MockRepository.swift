//
//  MockRepository.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import Combine
@testable import FootballApp

class MockRepository: RepositoryProtocol {
    var playersAndTeamsResponse: Result<PlayersAndTeams, RepositoryError> = .failure(.playersAndTeamsService(.unableToConstructURL))
    let favouritePlayers: CurrentValueSubject<[Player], Never> = .init([])

    func getPlayersAndTeams(searchText: String) -> AnyPublisher<PlayersAndTeams, RepositoryError> {
        Future { [unowned self] promise in
            promise(self.playersAndTeamsResponse)
        }
        .delay(for: 2, scheduler: DispatchQueue.global())
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }

    func getPlayers(searchText: String, offset: Int) -> AnyPublisher<[Player], RepositoryError> {
        Fail(error: .playersAndTeamsService(.unableToConstructURL))
            .eraseToAnyPublisher()
    }

    func getTeams(searchText: String, offset: Int) -> AnyPublisher<[Team], RepositoryError> {
        Fail(error: .playersAndTeamsService(.unableToConstructURL))
            .eraseToAnyPublisher()
    }

    func addPlayerToFavourites(_ player: Player) {
        favouritePlayers.value.append(player)
    }

    func removePlayerFromFavourites(_ player: Player) {
        favouritePlayers.value.removeAll(where: { $0.id == player.id })
    }

    func getFavouritePlayersIDs(lookup: String) -> AnyPublisher<Set<Player.ID>, Never> {
        favouritePlayers
            .map {
                $0
                    .filter { $0.firstName.contains(lookup) || $0.secondName.contains(lookup) }
                    .map(\.id)
            }
            .map(Set.init)
            .eraseToAnyPublisher()
    }

    func getAllFavouritePlayers() -> AnyPublisher<[Player], Never> {
        favouritePlayers
            .eraseToAnyPublisher()
    }

    func getFlags() -> AnyPublisher<[String : String], RepositoryError> {
        Just([:])
            .setFailureType(to: RepositoryError.self)
            .eraseToAnyPublisher()
    }
}
