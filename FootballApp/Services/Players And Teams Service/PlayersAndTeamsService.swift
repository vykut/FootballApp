//
//  PlayersAndTeamsService.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation
import Combine

enum PlayersAndTeamsServiceError: Error {
    case unableToConstructURL
    case network(Network.Error)
}

final class PlayersAndTeamsService: PlayersAndTeamsServiceProtocol {
    static private let baseURL: String = "https://trials.mtcmobile.co.uk/api/football/1.0/"

    static let shared: PlayersAndTeamsService = .init()

    private init() { }

    func fetchPlayersAndTeams(body: PlayersAndTeamsRequest) -> AnyPublisher<PlayersAndTeams.NetworkResponse, PlayersAndTeamsServiceError> {
        getBaseURL()
            .map { url -> URL in
                url.appendingPathComponent(Path.search.rawValue)
            }
            .map { url -> Network.Request<PlayersAndTeamsRequest> in
                .post(baseURL: url, payload: body)
            }
            .flatMap { request in
                Network.makeRequest(request)
                    .mapError { .network($0) }
                    .map(\.value)
            }
            .subscribe(on: Threads.playersAndTeamsServiceThread)
            .eraseToAnyPublisher()
    }

    private func getBaseURL() -> AnyPublisher<URL, PlayersAndTeamsServiceError> {
        guard let url = URL(string: Self.baseURL) else {
            return Fail(error: .unableToConstructURL)
                .eraseToAnyPublisher()
        }

        return Just(url)
            .setFailureType(to: PlayersAndTeamsServiceError.self)
            .eraseToAnyPublisher()
    }
}

extension PlayersAndTeamsService {
    enum Path: String {
        case search
    }
}
