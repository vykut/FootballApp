//
//  PlayersAndTeamsRequest.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

struct PlayersAndTeams: Hashable, Decodable {
    var players: [Player]
    var teams: [Team]
    let status: Bool
    let message: String
    let requestOrder: Int
    let searchType: PlayersAndTeamsSearchType?
    let searchString: String
    let serverAlert: String

    var isEmpty: Bool {
        players.isEmpty && teams.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case players
        case teams
        case status
        case message
        case requestOrder = "request_order"
        case searchType
        case searchString
        case serverAlert
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.players = try container.decodeIfPresent([Player].self, forKey: .players) ?? []
        self.teams = try container.decodeIfPresent([Team].self, forKey: .teams) ?? []
        self.status = try container.decode(Bool.self, forKey: .status)
        self.message = try container.decode(String.self, forKey: .message)
        self.requestOrder = try container.decode(Int.self, forKey: .requestOrder)
        self.searchType = try? container.decode(PlayersAndTeamsSearchType.self, forKey: .searchType)
        self.searchString = try container.decode(String.self, forKey: .searchString)
        self.serverAlert = try container.decode(String.self, forKey: .serverAlert)
    }
}

extension PlayersAndTeams {
    struct NetworkResponse: Decodable {
        let result: PlayersAndTeams
    }
}
