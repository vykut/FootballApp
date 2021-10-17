//
//  PlayersAndTeamsServiceProtocol.swift
//  FootballApp
//
//  Created by vsocaciu on 17.10.2021.
//

import Foundation
import Combine

protocol PlayersAndTeamsServiceProtocol {
    func fetchPlayersAndTeams(body: PlayersAndTeamsRequest) -> AnyPublisher<PlayersAndTeams.NetworkResponse, PlayersAndTeamsServiceError>
}
