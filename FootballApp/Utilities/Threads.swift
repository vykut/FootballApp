//
//  Threads.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

enum Threads {
    static let playersAndTeamsServiceThread: DispatchQueue = .init(label: "service-playersAndTeams", qos: .userInitiated)
    static let flagsThread: DispatchQueue = .init(label: "flags", qos: .utility)
    static let localStorageServiceThread: DispatchQueue = .init(label: "service-localStorage", qos: .userInitiated)
}
