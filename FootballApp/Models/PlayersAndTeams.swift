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
    let searchString: String

    enum CodingKeys: String, CodingKey {
        case players
        case teams
        case searchString
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.players = try container.decodeIfPresent([Player].self, forKey: .players) ?? []
        self.teams = try container.decodeIfPresent([Team].self, forKey: .teams) ?? []
        self.searchString = try container.decode(String.self, forKey: .searchString)
    }
}

extension PlayersAndTeams {
    struct NetworkResponse: Decodable {
        let result: PlayersAndTeams
    }
}
