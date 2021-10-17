//
//  MockPlayersAndTeamsService.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import Combine

@testable import FootballApp

class MockPlayersAndTeamsService: PlayersAndTeamsServiceProtocol {
    func fetchPlayersAndTeams(body: PlayersAndTeamsRequest) -> AnyPublisher<PlayersAndTeams.NetworkResponse, PlayersAndTeamsServiceError> {
        Fail(error: .unableToConstructURL)
            .eraseToAnyPublisher()
    }
}
