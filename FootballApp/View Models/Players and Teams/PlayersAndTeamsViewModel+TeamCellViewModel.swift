//
//  PlayersAndTeamsViewModel+TeamCellViewModel.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

extension PlayersAndTeamsViewModel {
    struct TeamCellViewModel {
        let name: String
        let city: String
        let stadium: String
        let flag: String

        init(team: Team, flag: String?) {
            self.name = team.name
            self.city = team.city
            self.stadium = team.stadium
            self.flag = flag ?? ""
        }
    }
}

extension PlayersAndTeamsViewModel.TeamCellViewModel {
    var cityTitle: String {
        "City"
    }

    var cityStadium: String {
        "Stadium"
    }
}
