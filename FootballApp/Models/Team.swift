//
//  Team.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

struct Team: Identifiable, Hashable, Decodable {
    let id: String
    let name: String
    let stadium: String
    let nationality: String
    let city: String

    enum CodingKeys: String, CodingKey {
        case id = "teamID"
        case name = "teamName"
        case stadium = "teamStadium"
        case nationality = "teamNationality"
        case city = "teamCity"
    }
}

extension Team {
    static func previewObject(
        name: String = "Monaco",
        stadium: String = "Stade Louis-II",
        nationality: String = "France",
        city: String = "Monaco"
    ) -> Self {
        .init(
            id: UUID().description,
            name: name,
            stadium: stadium,
            nationality: nationality,
            city: city
        )
    }
}
