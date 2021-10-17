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

    init(players: [Player], teams: [Team], searchString: String) {
        self.players = players
        self.teams = teams
        self.searchString = searchString
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.players = try container.decodeIfPresent([Player].self, forKey: .players) ?? []
        self.teams = try container.decodeIfPresent([Team].self, forKey: .teams) ?? []
        self.searchString = try container.decode(String.self, forKey: .searchString)
    }

    enum CodingKeys: String, CodingKey {
        case players
        case teams
        case searchString
    }
}

extension PlayersAndTeams {
    struct NetworkResponse: Decodable {
        let result: PlayersAndTeams
    }
}

extension PlayersAndTeams {
    static func previewObject(
        players: [Player] = [.previewObject()],
        teams: [Team] = [.previewObject()],
        searchString: String = ""
    ) -> Self {
        .init(
            players: players,
            teams: teams,
            searchString: searchString
        )
    }
}
