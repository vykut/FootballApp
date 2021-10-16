//
//  Player.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

struct Player: Identifiable, Hashable, Decodable {
    let id: String
    let firstName: String
    let secondName: String
    let nationality: String
    let age: String
    let club: String

    /// since `age` is a String, we'll try to parse it as Int
    var intAge: Int? {
        Int(age)
    }

    enum CodingKeys: String, CodingKey {
        case id = "playerID"
        case firstName = "playerFirstName"
        case secondName = "playerSecondName"
        case nationality = "playerNationality"
        case age = "playerAge"
        case club = "playerClub"
    }
}

extension Player {
    static func previewObject(
        firstName: String = "Victor",
        secondName: String = "Socaciu",
        nationality: String = "Romanian",
        age: String = "24",
        club: String = "FCSB"
    ) -> Self {
        .init(
            id: UUID().description,
            firstName: firstName,
            secondName: secondName,
            nationality: nationality,
            age: age,
            club: club
        )
    }
}

extension Player {
    var displayName: String {
        if firstName.isEmpty {
            return secondName
        }
        if secondName.isEmpty {
            return firstName
        }

        return "\(firstName) \(secondName)"
    }
}
