//
//  PlayersAndTeamsRequest.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

struct PlayersAndTeamsRequest: Encodable {
    let searchString: String
    let searchType: PlayersAndTeamsSearchType?
    let offset: Int?
    let requestOrder: Int?
}
