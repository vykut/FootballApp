//
//  LocalStorageServiceProtocol.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import Combine

protocol LocalStorageServiceProtocol {
    func addPlayerToFavourites(_ player: Player)
    func removePlayerFromFavourites(_ player: Player)
    func getAllFavouritePlayers() -> AnyPublisher<[FavouritePlayer], Never>
    func lookupFavouritePlayers(_ lookup: String) -> AnyPublisher<[FavouritePlayer], Never>
}
