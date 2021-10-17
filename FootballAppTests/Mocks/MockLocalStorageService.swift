//
//  MockLocalStorageService.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import Combine

@testable import FootballApp

class MockLocalStorageService: LocalStorageServiceProtocol {
    func addPlayerToFavourites(_ player: Player) {
        
    }

    func removePlayerFromFavourites(_ player: Player) {
        
    }

    func getAllFavouritePlayers() -> AnyPublisher<[FavouritePlayer], Never> {
        Just([])
            .eraseToAnyPublisher()
    }

    let favouritePlayers: CurrentValueSubject<[FavouritePlayer], Never> = .init([])

    func lookupFavouritePlayers(_ lookup: String) -> AnyPublisher<[FavouritePlayer], Never> {
        favouritePlayers
            .map { $0.filter { $0.firstName?.contains(lookup) == true || $0.secondName?.contains(lookup) == true } }
            .eraseToAnyPublisher()
    }
}
