//
//  PlayersAndTeamsViewModel+PlayerCellViewModel.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

extension PlayersAndTeamsViewModel {
    struct PlayerCellViewModel {
        let name: String
        let age: String
        let club: String
        let isFavourite: Bool

        init(player: Player, isFavourite: Bool) {
            self.name = player.displayName
            self.age = player.age
            self.club = player.club
            self.isFavourite = isFavourite
        }
    }
}

extension PlayersAndTeamsViewModel.PlayerCellViewModel {
    var ageTitle: String {
        "Age"
    }

    var clubTitle: String {
        "Club"
    }
}
