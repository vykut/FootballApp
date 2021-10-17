//
//  RepositoryProtocol.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import Combine

/// a protocol oriented approach that let's us mock the Repository layer, for unit testing purposes
protocol RepositoryProtocol {
    func getPlayersAndTeams(searchText: String) -> AnyPublisher<PlayersAndTeams, RepositoryError>
    func getPlayers(searchText: String, offset: Int) -> AnyPublisher<[Player], RepositoryError>
    func getTeams(searchText: String, offset: Int) -> AnyPublisher<[Team], RepositoryError>

    func addPlayerToFavourites(_ player: Player)
    func removePlayerFromFavourites(_ player: Player)
    func getFavouritePlayersIDs(lookup: String) -> AnyPublisher<Set<Player.ID>, Never>
    func getAllFavouritePlayers() -> AnyPublisher<[Player], Never>

    func getFlags() -> AnyPublisher<[String: String], RepositoryError>
}
