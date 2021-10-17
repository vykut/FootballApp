//
//  RepositoryTests.swift
//  FootballAppTests
//
//  Created by vsocaciu on 17.10.2021.
//

import XCTest
import Combine

@testable import FootballApp

class RepositoryTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []

    func testRepository_methodGetFavouritePlayersIDs_forLookup_shouldReturnFavouritePlayersIDs() throws {
        let mockLocalStorageService: MockLocalStorageService = .init()
        mockLocalStorageService.favouritePlayers.value.append(.init())
        mockLocalStorageService.favouritePlayers.value.append(.init())
        mockLocalStorageService.favouritePlayers.value.append(.init())

        let repository: Repository = .getMockRepository(
            playersAndTeamsService: MockPlayersAndTeamsService(),
            localStorageService: MockLocalStorageService()
        )

        repository
            .getFavouritePlayersIDs(lookup: "berc")
            .sink { players in
                XCTAssertEqual(players, [])
            }
            .store(in: &subscriptions)
    }
}
