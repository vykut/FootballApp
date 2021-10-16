//
//  Network+Error.swift
//  FootballApp
//
//  Created by vsocaciu on 16.10.2021.
//

import Foundation

extension Network {
    enum Error: Swift.Error {
        case unableToConstructRequest
        case unableToDecode(Swift.Error)
        case network(statusCode: Int)
        case unknown
    }
}
